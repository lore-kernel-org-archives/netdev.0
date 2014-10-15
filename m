From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCHv3 RFC net-next 1/4] sunvnet: NAPIfy sunvnet
Date: Wed, 15 Oct 2014 13:22:04 -0400
Message-ID: <20141015172204.GF11840@oracle.com>
References: <20141015164252.GB11840@oracle.com>
 <543EAC34.1010502@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, bob.picco@oracle.com, dwight.engen@oracle.com,
	raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:33366 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758AbaJORWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 13:22:09 -0400
Content-Disposition: inline
In-Reply-To: <543EAC34.1010502@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (10/15/14 13:17), David L Stevens wrote:
> > -static void maybe_tx_wakeup(unsigned long param)
> > +static void maybe_tx_wakeup(struct vnet *vp)
> >  {
> > -	struct vnet *vp = (struct vnet *)param;
> >  	struct net_device *dev = vp->dev;
> >  
> >  	netif_tx_lock(dev);
> 
> Isn't this a function type conflict for tasklet_init()?

maybe_tx_wakeup is not a tasklet any more. That was one of the
big benefits of going NAPI, as David Miller pointed out- we
are already in NAPI context, so the original reason (deadlock
with dev_watchdog) does not exist any more.

I'm working on adding the rest of your comments about
removing comments and making an int into a bool.

--Sowmini
