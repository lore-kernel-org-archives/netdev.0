From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: RE: [PATCH] Increase virtual FIFOs in ucc_geth.
Date: Wed, 12 Dec 2007 14:08:58 +0100
Message-ID: <1197464938.6790.35.camel@gentoo-jocke.transmode.se>
References: <1197312366-7484-1-git-send-email-Joakim.Tjernlund@transmode.se>
	 <989B956029373F45A0B8AF029708189001B4D901@zch01exm26.fsl.freescale.net>
	 <1197367919.6790.3.camel@gentoo-jocke.transmode.se>
	 <1197370676.6790.17.camel@gentoo-jocke.transmode.se>
	 <989B956029373F45A0B8AF029708189001B4D908@zch01exm26.fsl.freescale.net>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Li Yang <LeoLi@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:15678 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751973AbXLLNJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 08:09:01 -0500
In-Reply-To: <989B956029373F45A0B8AF029708189001B4D908@zch01exm26.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2007-12-11 at 19:51 +0800, Li Yang wrote:
> > -----Original Message-----
> > From: Joakim Tjernlund [mailto:joakim.tjernlund@transmode.se] 
> > Sent: Tuesday, December 11, 2007 6:58 PM
> > To: Li Yang
> > Cc: netdev@vger.kernel.org
> > Subject: RE: [PATCH] Increase virtual FIFOs in ucc_geth.
> > 
> > 
> > On Tue, 2007-12-11 at 11:11 +0100, Joakim Tjernlund wrote:
> > > On Tue, 2007-12-11 at 17:49 +0800, Li Yang wrote:
> > > > > -----Original Message-----
> > > > > From: Joakim Tjernlund [mailto:Joakim.Tjernlund@transmode.se] 
> > > > > Sent: Tuesday, December 11, 2007 2:46 AM
> > > > > To: Li Yang-r58472 <LeoLi@freescale.com> Netdev
> > > > > Cc: Joakim Tjernlund
> > > > > Subject: [PATCH] Increase virtual FIFOs in ucc_geth.
> > > > > 
> > > > > Increase UCC_GETH_URFS_INIT to 1152 and
> > > > > UCC_GETH_UTFS_INIT to 896 to avoid HW Overrun/Underrun.
> > > > 
> > > > Please be noted that these values are only used for 
> > 10/100Mbps speed.
> > > > Did you get Overrun in 10/100M mode?
> > > 
> > > I get both TX Underrun and RX overrun in 100Mbps, FD, just
> > > by running a tftp transfer. It feels like the URFET and/or URSFET
> > > isn't working. Why I don't know. CPU is MPC832x
> > > 
> > >   Jocke
> > 
> > I am a bit confused how the RBMR and TBMR is supposed to work. In
> > ucc_get there is:
> >  out_be32(&ugeth->p_tx_glbl_pram->tstate, ((u32) 
> > function_code) << 24);
> >  ugeth->p_rx_glbl_pram->rstate = function_code;
> > First, should not the rx part look the same as tx?
> 
> To be consist with the chip RM, type for tstate is u32 and type for
> rstate is u8.  Personally I don't think that it will be different to
> access tstate as u8, but it will be more readable to be the same as
> manual.  Well, rstate probably should be changed to use IO accessor too.
> 
> > Does programing rstate/tstate replace RBMR and TBMR?
> 
> RBMR and TBMR?  These are for other protocols.
> 
> - Leo

Noticed that the number of threads(numThreadsTx and numThreadsRx) is set
to 4. That is a good value for GBE, but the manual thinks 1 is good for
10/100 Mbps. How does 4 threads affect the FIFO for 100 Mbps? I can't 
test ATM as the system is busy with other things.

  Jocke 
