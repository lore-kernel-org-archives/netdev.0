From: "Li Yang" <LeoLi@freescale.com>
Subject: RE: [PATCH] ucc_geth_ethtool: Fix a few HW stats counters.
Date: Thu, 15 May 2008 11:03:24 +0800
Message-ID: <989B956029373F45A0B8AF0297081890022E142D@zch01exm26.fsl.freescale.net>
References: <1210665877-6590-1-git-send-email-Joakim.Tjernlund@transmode.se> <989B956029373F45A0B8AF0297081890022E13C3@zch01exm26.fsl.freescale.net> <1210762175.32216.295.camel@gentoo-jocke.transmode.se>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Netdev" <netdev@vger.kernel.org>
To: <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:44702 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708AbYEODDf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 23:03:35 -0400
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by de01egw01.freescale.net (8.12.11/az33egw01) with ESMTP id m4F33Up4022351
	for <netdev@vger.kernel.org>; Wed, 14 May 2008 20:03:31 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id m4F33SnO023547
	for <netdev@vger.kernel.org>; Wed, 14 May 2008 22:03:29 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <1210762175.32216.295.camel@gentoo-jocke.transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Joakim Tjernlund [mailto:joakim.tjernlund@transmode.se] 
> Sent: Wednesday, May 14, 2008 6:50 PM
> To: Li Yang
> Cc: Netdev
> Subject: RE: [PATCH] ucc_geth_ethtool: Fix a few HW stats counters.
> 
> I didn't see them in my manual so I figured they were extra. 
> If you find them please let me know where.

I'm reading from MPC8360ERM Rev. 2.  They have the following definition:

UCCx_BASE+0x1C4  Frames discarded due to overrun condition in the
RxFIFO.
REBASE+5C Counts the total number of fames that have an IPChecsum Error.

Which manual are you using?

- Leo
> 
> On Wed, 2008-05-14 at 18:37 +0800, Li Yang wrote:
> > Hi Joakim,
> > 
> > I admit that I missed one in tx firmware stats.  But why are you 
> > deleting the other two?
> > 
> > - Leo
> > 
> > > -----Original Message-----
> > > From: Joakim Tjernlund [mailto:Joakim.Tjernlund@transmode.se]
> > > Sent: Tuesday, May 13, 2008 4:05 PM
> > > To: Netdev; Li Yang
> > > Cc: Joakim Tjernlund
> > > Subject: [PATCH] ucc_geth_ethtool: Fix a few HW stats counters.
> > > 
> > > Noticed that ethtool -S didn't display tx-xxx-frames correctly.
> > > Fix it and a few others while I am there. Strangely, the 
> > > rx-jumbo-frames counter still counts pkgs even though I 
> think there 
> > > isn't any packtes above 1518.
> > > 
> > > Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> > > ---
> > > 
> > > Havn't seen this go in or ACK/NACK. Resending.
> > > 
> > >  drivers/net/ucc_geth_ethtool.c |    3 +--
> > >  1 files changed, 1 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/drivers/net/ucc_geth_ethtool.c 
> > > b/drivers/net/ucc_geth_ethtool.c index a995a3a..0eddf50 100644
> > > --- a/drivers/net/ucc_geth_ethtool.c
> > > +++ b/drivers/net/ucc_geth_ethtool.c
> > > @@ -60,7 +60,6 @@ static char 
> hw_stat_gstrings[][ETH_GSTRING_LEN] = {
> > >  	"rx-broadcast-frames",
> > >  	"stats-counter-carry",
> > >  	"stats-counter-mask",
> > > -	"rx-dropped-frames",
> > >  };
> > >  
> > >  static char tx_fw_stat_gstrings[][ETH_GSTRING_LEN] = { @@
> > > -73,6 +72,7 @@ static char 
> tx_fw_stat_gstrings[][ETH_GSTRING_LEN] = {
> > >  	"tx-frames-ok",
> > >  	"tx-excessive-differ-frames",
> > >  	"tx-256-511-frames",
> > > +	"tx-512-1023-frames",
> > >  	"tx-1024-1518-frames",
> > >  	"tx-jumbo-frames",
> > >  };
> > > @@ -101,7 +101,6 @@ static char
> > > rx_fw_stat_gstrings[][ETH_GSTRING_LEN] = {
> > >  	"rx-vlan-removed",
> > >  	"rx-vlan-replaced",
> > >  	"rx-vlan-inserted",
> > > -	"rx-ip-checksum-errors",
> > >  };
> > >  
> > >  #define UEC_HW_STATS_LEN ARRAY_SIZE(hw_stat_gstrings)
> > > --
> > > 1.5.5.1
> > > 
> > > 
> > 
> > 
> 
