From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 6/7] sctp: Correct access to
 skb->{network,transport}_header
Date: Fri, 31 May 2013 15:21:37 +0900
Message-ID: <20130531062137.GF5009@verge.net.au>
References: <1369805268-6291-1-git-send-email-horms@verge.net.au>
 <1369805268-6291-7-git-send-email-horms@verge.net.au>
 <1369855872.1971.1.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:39300 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752206Ab3EaG3a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 02:29:30 -0400
Content-Disposition: inline
In-Reply-To: <1369855872.1971.1.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 29, 2013 at 08:31:12PM +0100, Ben Hutchings wrote:
> On Wed, 2013-05-29 at 14:27 +0900, Simon Horman wrote:
> > This corrects an regression introduced by "net: Use 16bits for *_headers
> > fields of struct skbuff" when NET_SKBUFF_DATA_USES_OFFSET is not set.
> 
> So how about adding 'typedef u16 sk_buff_data_t;'?
> 
> > In
> > that case sk_buff_data_t will be a pointer, however,
> > skb->{network,transport}_header is now __u16.
> > 
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> > ---
> >  net/sctp/input.c |    2 +-
> >  net/sctp/ipv6.c  |    2 +-
> >  2 files changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/net/sctp/input.c b/net/sctp/input.c
> > index 4b2c831..e328fe8 100644
> > --- a/net/sctp/input.c
> > +++ b/net/sctp/input.c
> > @@ -589,7 +589,7 @@ void sctp_v4_err(struct sk_buff *skb, __u32 info)
> >  	struct sctp_association *asoc = NULL;
> >  	struct sctp_transport *transport;
> >  	struct inet_sock *inet;
> > -	sk_buff_data_t saveip, savesctp;
> > +	__be16 saveip, savesctp;
> [...]
> 
> __be16??

Ooops. I will fix that.
