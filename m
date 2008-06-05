From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: PATCH: fix bridged 802.3ad bonding
Date: Thu, 5 Jun 2008 12:13:20 +0200
Message-ID: <20080605101319.GA3756@midget.suse.cz>
References: <20080603132106.GA3256@midget.suse.cz> <20080603094604.6a7dfe7d@extreme> <20080603193227.GA4050@midget.suse.cz> <20080603131326.1f70915e@extreme> <18105.1212528128@death> <20080603215519.298c0cd3@extreme> <20080604082425.GA3272@midget.suse.cz> <20080604090633.2a12cecc@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Bohac <jbohac@suse.cz>, Jay Vosburgh <fubar@us.ibm.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:51050 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753989AbYFEKNV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2008 06:13:21 -0400
Content-Disposition: inline
In-Reply-To: <20080604090633.2a12cecc@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 04, 2008 at 09:06:33AM -0700, Stephen Hemminger wrote:
> On Wed, 4 Jun 2008 10:24:25 +0200
> Jiri Bohac <jbohac@suse.cz> wrote:
> 
> > On Tue, Jun 03, 2008 at 09:55:19PM -0700, Stephen Hemminger wrote:
> > >
> > > --- a/net/bridge/br_input.c	2008-06-03 21:44:54.000000000 -0700
> > > +++ b/net/bridge/br_input.c	2008-06-03 21:52:20.000000000 -0700
> > > @@ -135,15 +135,12 @@ struct sk_buff *br_handle_frame(struct n
> > >  		/* Pause frames shouldn't be passed up by driver anyway */
> > >  		if (skb->protocol == htons(ETH_P_PAUSE))
> > >  			goto drop;
> > > -
> > > -		/* Process STP BPDU's through normal netif_receive_skb() path */
> > > -		if (p->br->stp_enabled != BR_NO_STP) {
> > > -			if (NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
> > > -				    NULL, br_handle_local_finish))
> > > -				return NULL;
> > > -			else
> > > -				return skb;
> > > -		}
> > > +
> > > +		if (NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
> > > +			    NULL, br_handle_local_finish))
> > > +			return NULL;	/* frame consumed by filter */
> > > +		else
> > > +			return skb;	/* continue processing */
> > >  	}
> > >  
> > >  	switch (p->state) {
> > 
> > where did the "if (p->br->stp_enabled != BR_NO_STP)" condition
> > go? Is it not needed? I thought it was there to prevent the STP
> > BPDUs from being handled when STP is turned off.
> > 
> 
> That is already done in br_stp_rcv so the check here was not
> needed.

Ah, I see. So can we get one of the patches in? I still think
that running the LACP frames through the bridging NF hooks does
not make sense, but it's your call.

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

