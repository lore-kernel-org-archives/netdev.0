From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next 3/8] bridge: implement BPDU blocking
Date: Wed, 31 Oct 2012 13:57:48 -0700
Message-ID: <20121031135748.60a89df3@s6510.linuxnetplumber.net>
References: <20121030005731.843020405@vyatta.com>
	<20121030005835.462418417@vyatta.com>
	<k6q2vm$1ug$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36741 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760559Ab2JaU55 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2012 16:57:57 -0400
In-Reply-To: <k6q2vm$1ug$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 31 Oct 2012 02:38:46 +0000 (UTC)
Cong Wang <xiyou.wangcong@gmail.com> wrote:

> On Tue, 30 Oct 2012 at 00:57 GMT, Stephen Hemminger <shemminger@vyatta.com> wrote:
> > --- a/net/bridge/br_stp_bpdu.c	2012-10-29 17:07:08.005982838 -0700
> > +++ b/net/bridge/br_stp_bpdu.c	2012-10-29 17:31:14.327457434 -0700
> > @@ -170,6 +170,13 @@ void br_stp_rcv(const struct stp_proto *
> >  	if (!ether_addr_equal(dest, br->group_addr))
> >  		goto out;
> >  
> > +	if (p->flags & BR_BPDU_GUARD) {
> > +		br_notice(br, "BPDU received on blocked port %u(%s)\n",
> > +			  (unsigned int) p->port_no, p->dev->name);
> 
> net_ratelimit() ?
> 

Not necessary since this causes port of bridge to become disabled;
which blocks all further packets (including STP) until manually reset.
