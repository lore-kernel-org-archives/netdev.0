From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [net-next v4 2/8] dpaa_eth: add support for DPAA Ethernet
Date: Tue, 3 Nov 2015 11:23:14 +0000
Message-ID: <1446549794.21216.56.camel@transmode.se>
References: <1446485500-9782-1-git-send-email-madalin.bucur@freescale.com>
	 <1446485500-9782-3-git-send-email-madalin.bucur@freescale.com>
	 <1446537357.21216.49.camel@transmode.se>
	 <BL2PR03MB545ED95392F5CB88EC06B11E62B0@BL2PR03MB545.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "scottwood@freescale.com" <scottwood@freescale.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"ppc@mindchasers.com" <ppc@mindchasers.com>,
	"roy.pledge@freescale.com" <roy.pledge@freescale.com>,
	"Igal.Liberman@freescale.com" <Igal.Liberman@freescale.com>,
	"pebolle@tiscali.nl" <pebolle@tiscali.nl>,
	"joe@perches.com" <joe@perches.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"madalin.bucur@freescale.com" <madalin.bucur@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BL2PR03MB545ED95392F5CB88EC06B11E62B0@BL2PR03MB545.namprd03.prod.outlook.com>
Content-Language: en-US
Content-ID: <4A4F491F78A4DC459BED8B95D14A1BD2@transmode.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-11-03 at 09:37 +0000, Madalin-Cristian Bucur wrote:
> > -----Original Message-----
> > From: Joakim Tjernlund [mailto:joakim.tjernlund@transmode.se]
> > 
> > On Mon, 2015-11-02 at 19:31 +0200, Madalin Bucur wrote:
> > > +       if (unlikely(fd_status & FM_FD_STAT_RX_ERRORS) != 0) {
> > > +               if (net_ratelimit())
> > > +                       netif_warn(priv, hw, net_dev, "FD status =
> > 0x%08x\n",
> > > +                                  fd_status & FM_FD_STAT_RX_ERRORS);
> > > +
> > > +               percpu_stats->rx_errors++;
> > > +               goto _release_frame;
> > > +       }
> > 
> > I cannot find any detailed error accounting(maybe I am not looking hard
> > enough) but I
> > would appreciate if both TX and RX errors where better
> > accounted(rx_length_errors, rx_frame_errors,
> > rx_crc_errors, rx_fifo_errors etc.). This has helped me many times in the
> > past diagnosing
> > board HW problems.
> > 
> >  Jocke
> 
> Hi Jocke,
> 
> There are some error counters exported through ethtool (used to be debugfs).
> FMan HW provides more debug information than we currently export, that will be
> improved in the future but given the current priority of having a codebase as
> small and reviewable as possible we had to drop some things from the initial
> submission.

I know, but ethtool is not always available.
Even the old fec_main.c has it:
 		if (status & (BD_ENET_RX_LG | BD_ENET_RX_SH | BD_ENET_RX_NO |
			   BD_ENET_RX_CR | BD_ENET_RX_OV)) {
			ndev->stats.rx_errors++;
			if (status & (BD_ENET_RX_LG | BD_ENET_RX_SH)) {
				/* Frame too long or too short. */
				ndev->stats.rx_length_errors++;
			}
			if (status & BD_ENET_RX_NO)	/* Frame alignment */
				ndev->stats.rx_frame_errors++;
			if (status & BD_ENET_RX_CR)	/* CRC Error */
				ndev->stats.rx_crc_errors++;
			if (status & BD_ENET_RX_OV)	/* FIFO overrun */
				ndev->stats.rx_fifo_errors++;
		}
so it is just a few more lines ... Pretty please ? :)

 Jocke
