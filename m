From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] netlink: Mark dumps as inconsistent which have been
 interrupted by a resize
Date: Wed, 21 Jan 2015 12:17:48 +0000
Message-ID: <20150121121748.GD12570@casper.infradead.org>
References: <cover.1421759056.git.tgraf@suug.ch>
 <cce004895ab6bcef267e2133a1c7ecab0fac403b.1421759056.git.tgraf@suug.ch>
 <54BF5FC4.4070808@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kaber@trash.net, herbert@gondor.apana.org.au,
	paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:36424 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812AbbAUMRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 07:17:51 -0500
Content-Disposition: inline
In-Reply-To: <54BF5FC4.4070808@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/21/15 at 04:13pm, Ying Xue wrote:
> On 01/20/2015 09:20 PM, Thomas Graf wrote:
> > A deferred resize of nl_table causes the offsets that Netlink diag keeps
> > to become inaccurate. Mark the dump as inconsistent and have user space
> > request a new dump.
> > 
> > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> > ---
> >  net/netlink/af_netlink.c | 10 ++++++++++
> >  net/netlink/af_netlink.h |  1 +
> >  net/netlink/diag.c       |  1 +
> >  3 files changed, 12 insertions(+)
> > 
> > diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> > index 7a94185..e214557 100644
> > --- a/net/netlink/af_netlink.c
> > +++ b/net/netlink/af_netlink.c
> > @@ -91,6 +91,9 @@ static inline int netlink_is_kernel(struct sock *sk)
> >  struct netlink_table *nl_table;
> >  EXPORT_SYMBOL_GPL(nl_table);
> >  
> > +atomic_t nl_table_seq;
> 
> It sounds like the atomic variable is not initialized.

Thanks for the review. We also need to avoid hitting 0 when we overflow
on a seq increment.  The netfilter code is doing this correctly but several
other users are suffering from this as well.

I'll address this in v2 together with the other discussed changes.
