From: hayeswang <hayeswang@realtek.com>
Subject: RE: [net-next-2.6 08/08] r8169: more 8168dp support.
Date: Tue, 4 Jan 2011 10:43:43 +0800
Message-ID: <FFFEF1293F9B4E3B81D3777F91F21B01@realtek.com.tw>
References: <20110102233751.GI5780@electric-eye.fr.zoreil.com>     <C4B63551EF6C4B57BB20D6922F78AA12@realtek.com.tw> <20110104002606.GA5934@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	'Ben Hutchings' <benh@debian.org>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtitmf2.realtek.com.tw ([60.250.210.236]:3960 "EHLO
	mf2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750855Ab1ADCnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 21:43:45 -0500
In-Reply-To: <20110104002606.GA5934@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Tuesday, January 04, 2011 8:26 AM
> To: Hayeswang
> Cc: davem@davemloft.net; netdev@vger.kernel.org; 'Ben Hutchings'
> Subject: Re: [net-next-2.6 08/08] r8169: more 8168dp support.
> 
> hayeswang <hayeswang@realtek.com> :
> [...]
> > > +static void rtl8169_hw_reset(struct rtl8169_private *tp)
> > >  {
> > > +	void __iomem *ioaddr = tp->mmio_addr;
> > > +
> > >  	/* Disable interrupts */
> > >  	rtl8169_irq_mask_and_ack(ioaddr);
> > >  
> > > +	if (tp->mac_version == RTL_GIGA_MAC_VER_28) {
> > 
> > This check should include RTL_GIGA_MAC_VER_27.
> 
> Sure. I have a different (yet untested) patch for it. See below.
> 
> > > +		while (RTL_R8(TxPoll) & NPQ)
> > > +			udelay(20);
> > > +
> > > +	}
> > > +
> > >  	/* Reset the chipset */
> > >  	RTL_W8(ChipCmd, CmdReset);
> > >  
> > 
> > After the reset, there are something to do for RTL_GIGA_MAC_VER_27. 
> > You may check the soure code of realtek. Find "rtl8168_nic_reset".
> 
> Ok. Any comment about the patch below ? I wish it was more 
> expressive, especially the "mutex" magic.
> 

The chip of 8111DP has an embedded system inside. Thus, sometime the nic has to
told the embedded system what the nic is doing now. For this reason, you can
find the function "OOB_notify" in source code of realtek. Furthermore, we do a
software mutex to avoid the driver and system from accessing the same register.
When doing reset, the nic has to notify the embedded system and wait a response.
However, maybe the system accesses the same register at the same time, so the
embedded system and the driver implement the same method of software mutex to
prevent this situation.

 
Best Regards,
Hayes

