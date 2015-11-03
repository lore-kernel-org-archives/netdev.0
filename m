From: Madalin-Cristian Bucur <madalin.bucur@freescale.com>
Subject: RE: [net-next v4 2/8] dpaa_eth: add support for DPAA Ethernet
Date: Tue, 3 Nov 2015 13:21:55 +0000
Message-ID: <BL2PR03MB545A75266F5057F2128C22CE62B0@BL2PR03MB545.namprd03.prod.outlook.com>
References: <1446485500-9782-1-git-send-email-madalin.bucur@freescale.com>
	 <1446485500-9782-3-git-send-email-madalin.bucur@freescale.com>
	 <1446537357.21216.49.camel@transmode.se>
	 <BL2PR03MB545ED95392F5CB88EC06B11E62B0@BL2PR03MB545.namprd03.prod.outlook.com>
 <1446549794.21216.56.camel@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0128.outbound.protection.outlook.com ([65.55.169.128]:38206
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750741AbbKCNV5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 08:21:57 -0500
In-Reply-To: <1446549794.21216.56.camel@transmode.se>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Joakim Tjernlund [mailto:joakim.tjernlund@transmode.se]
> 
> On Tue, 2015-11-03 at 09:37 +0000, Madalin-Cristian Bucur wrote:
> > > -----Original Message-----
> > > From: Joakim Tjernlund [mailto:joakim.tjernlund@transmode.se]
> > >
> > > On Mon, 2015-11-02 at 19:31 +0200, Madalin Bucur wrote:
> > > > +       if (unlikely(fd_status & FM_FD_STAT_RX_ERRORS) != 0) {
> > > > +               if (net_ratelimit())
> > > > +                       netif_warn(priv, hw, net_dev, "FD status =
> > > 0x%08x\n",
> > > > +                                  fd_status &
> FM_FD_STAT_RX_ERRORS);
> > > > +
> > > > +               percpu_stats->rx_errors++;
> > > > +               goto _release_frame;
> > > > +       }
> > >
> > > I cannot find any detailed error accounting(maybe I am not looking
> hard
> > > enough) but I
> > > would appreciate if both TX and RX errors where better
> > > accounted(rx_length_errors, rx_frame_errors,
> > > rx_crc_errors, rx_fifo_errors etc.). This has helped me many times in
> the
> > > past diagnosing
> > > board HW problems.
> > >
> > >  Jocke
> >
> > Hi Jocke,
> >
> > There are some error counters exported through ethtool (used to be
> debugfs).
> > FMan HW provides more debug information than we currently export, that
> will be
> > improved in the future but given the current priority of having a
> codebase as
> > small and reviewable as possible we had to drop some things from the
> initial
> > submission.
> 
> I know, but ethtool is not always available.
> Even the old fec_main.c has it:
>  		if (status & (BD_ENET_RX_LG | BD_ENET_RX_SH | BD_ENET_RX_NO |
> 			   BD_ENET_RX_CR | BD_ENET_RX_OV)) {
> 			ndev->stats.rx_errors++;
> 			if (status & (BD_ENET_RX_LG | BD_ENET_RX_SH)) {
> 				/* Frame too long or too short. */
> 				ndev->stats.rx_length_errors++;
> 			}
> 			if (status & BD_ENET_RX_NO)	/* Frame alignment */
> 				ndev->stats.rx_frame_errors++;
> 			if (status & BD_ENET_RX_CR)	/* CRC Error */
> 				ndev->stats.rx_crc_errors++;
> 			if (status & BD_ENET_RX_OV)	/* FIFO overrun */
> 				ndev->stats.rx_fifo_errors++;
> 		}
> so it is just a few more lines ... Pretty please ? :)
> 
>  Jocke

It may be more that just a few lines to add complete debug details.
Your request is noted and will be among the first features to work on
after the driver is accepted upstream.

Thanks,
Madalin
