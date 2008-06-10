From: David Miller <davem@davemloft.net>
Subject: Re: PATCH: fix bridged 802.3ad bonding
Date: Tue, 10 Jun 2008 15:42:36 -0700 (PDT)
Message-ID: <20080610.154236.189971046.davem@davemloft.net>
References: <20080604082425.GA3272@midget.suse.cz>
	<20080604090633.2a12cecc@extreme>
	<20080605101319.GA3756@midget.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, fubar@us.ibm.com,
	netdev@vger.kernel.org
To: jbohac@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55018
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754437AbYFJWmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 18:42:40 -0400
In-Reply-To: <20080605101319.GA3756@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Bohac <jbohac@suse.cz>
Date: Thu, 5 Jun 2008 12:13:20 +0200

> On Wed, Jun 04, 2008 at 09:06:33AM -0700, Stephen Hemminger wrote:
> > On Wed, 4 Jun 2008 10:24:25 +0200
> > Jiri Bohac <jbohac@suse.cz> wrote:
> > 
> > > On Tue, Jun 03, 2008 at 09:55:19PM -0700, Stephen Hemminger wrote:
> > > >
> > > > --- a/net/bridge/br_input.c	2008-06-03 21:44:54.000000000 -0700
> > > > +++ b/net/bridge/br_input.c	2008-06-03 21:52:20.000000000 -0700
> > > > @@ -135,15 +135,12 @@ struct sk_buff *br_handle_frame(struct n
> > > >  		/* Pause frames shouldn't be passed up by driver anyway */
> > > >  		if (skb->protocol == htons(ETH_P_PAUSE))
> > > >  			goto drop;
> > > > -
> > > > -		/* Process STP BPDU's through normal netif_receive_skb() path */
> > > > -		if (p->br->stp_enabled != BR_NO_STP) {
> > > > -			if (NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
> > > > -				    NULL, br_handle_local_finish))
> > > > -				return NULL;
> > > > -			else
> > > > -				return skb;
> > > > -		}
> > > > +
> > > > +		if (NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
> > > > +			    NULL, br_handle_local_finish))
> > > > +			return NULL;	/* frame consumed by filter */
> > > > +		else
> > > > +			return skb;	/* continue processing */
> > > >  	}
> > > >  
> > > >  	switch (p->state) {
> > > 
> > > where did the "if (p->br->stp_enabled != BR_NO_STP)" condition
> > > go? Is it not needed? I thought it was there to prevent the STP
> > > BPDUs from being handled when STP is turned off.
> > > 
> > 
> > That is already done in br_stp_rcv so the check here was not
> > needed.
> 
> Ah, I see. So can we get one of the patches in? I still think
> that running the LACP frames through the bridging NF hooks does
> not make sense, but it's your call.

Stephen, if prefer your approach, please repost your patch with full
commit message and proper signoffs, thanks!
