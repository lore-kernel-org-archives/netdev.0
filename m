From: "Guan Xuetao" <gxt@mprc.pku.edu.cn>
Subject: RE: [PATCH 2/6] unicore32: add pkunity-v3 mac/net driver (umal)
Date: Sat, 28 May 2011 10:52:02 +0800
Message-ID: <002a01cc1ce2$39b0daa0$ad128fe0$@mprc.pku.edu.cn>
References: <cover.1306408804.git.gxt@mprc.pku.edu.cn> <556924396ee34f4af94a2f03767973f1cec35e22.1306408804.git.gxt@mprc.pku.edu.cn> <201105271119.41323.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <linux-arch@vger.kernel.org>,
	<greg@kroah.com>, <netdev@vger.kernel.org>
To: "'Arnd Bergmann'" <arnd@arndb.de>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <201105271119.41323.arnd@arndb.de>
Content-Language: zh-cn
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Arnd Bergmann [mailto:arnd@arndb.de]
> Sent: Friday, May 27, 2011 5:20 PM
> To: GuanXuetao
> Cc: linux-kernel@vger.kernel.org; linux-arch@vger.kernel.org; greg@kroah.com; netdev@vger.kernel.org
> Subject: Re: [PATCH 2/6] unicore32: add pkunity-v3 mac/net driver (umal)
> 
> On Thursday 26 May 2011, GuanXuetao wrote:
> > From: Guan Xuetao <gxt@mprc.pku.edu.cn>
> >
> > Signed-off-by: Guan Xuetao <gxt@mprc.pku.edu.cn>
> > ---
> >  MAINTAINERS                            |    1 +
> >  arch/unicore32/configs/debug_defconfig |    2 +-
> >  drivers/net/Kconfig                    |    5 +
> >  drivers/net/Makefile                   |    1 +
> >  drivers/net/mac-puv3.c                 | 1942 ++++++++++++++++++++++++++++++++
> >  5 files changed, 1950 insertions(+), 1 deletions(-)
> >  create mode 100644 drivers/net/mac-puv3.c
> 
> I also have a few comments after looking through the driver.
> 
> > +
> > +/**********************************************************************
> > + *  Globals
> > + ********************************************************************* */
> 
> Regular commenting style would be
> 
> /*
>  * Globals
>  */
> 
> > +/**********************************************************************
> > + *  Prototypes
> > + ********************************************************************* */
> > +static int umal_mii_reset(struct mii_bus *bus);
> > +static int umal_mii_read(struct mii_bus *bus, int phyaddr, int regidx);
> > +static int umal_mii_write(struct mii_bus *bus, int phyaddr, int regidx,
> > +		u16 val);
> > +static int umal_mii_probe(struct net_device *dev);
> > +
> > +static void umaldma_initctx(struct umaldma *d, struct umal_softc *s,
> > +		int rxtx, int maxdescr);
> > +static void umaldma_uninitctx(struct umaldma *d);
> > +static void umaldma_channel_start(struct umaldma *d, int rxtx);
> > +static void umaldma_channel_stop(struct umaldma *d);
> > +static int umaldma_add_rcvbuffer(struct umal_softc *sc, struct umaldma *d,
> > +		struct sk_buff *m);
> > +static int umaldma_add_txbuffer(struct umaldma *d, struct sk_buff *m);
> > +static void umaldma_emptyring(struct umaldma *d);
> > +static void umaldma_fillring(struct umal_softc *sc, struct umaldma *d);
> > +static int umaldma_rx_process(struct umal_softc *sc, struct umaldma *d,
> > +		int work_to_do, int poll);
> > +static void umaldma_tx_process(struct umal_softc *sc, struct umaldma *d,
> > +		int poll);
> > +
> > +static int umal_initctx(struct umal_softc *s);
> > +static void umal_uninitctx(struct umal_softc *s);
> > +static void umal_channel_start(struct umal_softc *s);
> > +static void umal_channel_stop(struct umal_softc *s);
> > +static enum umal_state umal_set_channel_state(struct umal_softc *,
> > +		enum umal_state);
> > +
> > +static int umal_init(struct platform_device *pldev, long long base);
> > +static int umal_open(struct net_device *dev);
> > +static int umal_close(struct net_device *dev);
> > +static int umal_mii_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
> > +static irqreturn_t umal_intr(int irq, void *dev_instance);
> > +static void umal_clr_intr(struct net_device *dev);
> > +static int umal_start_tx(struct sk_buff *skb, struct net_device *dev);
> > +static void umal_tx_timeout(struct net_device *dev);
> > +static void umal_set_rx_mode(struct net_device *dev);
> > +static void umal_promiscuous_mode(struct umal_softc *sc, int onoff);
> > +static void umal_setmulti(struct umal_softc *sc);
> > +static int umal_set_speed(struct umal_softc *s, enum umal_speed speed);
> > +static int umal_set_duplex(struct umal_softc *s, enum umal_duplex duplex,
> > +		enum umal_fc fc);
> > +static int umal_change_mtu(struct net_device *_dev, int new_mtu);
> > +static void umal_miipoll(struct net_device *dev);
> 
> Best avoid all these prototypes. Instead, reorder the functions in the
> driver so you don't need them. That is the order in which reviewers expect
> them.
> 
> > +/**********************************************************************
> > + *  UMAL_MII_RESET(bus)
> > + *
> > + *  Reset MII bus.
> > + *
> > + *  Input parameters:
> > + *	   bus     - MDIO bus handle
> > + *
> > + *  Return value:
> > + *	   0 if ok
> > + ********************************************************************* */
> 
> For extended function documentation, use the kerneldoc style, e.g.
> 
> /**
>  * umal_mii_reset - reset MII bus
>  *
>  * @bus: MDIO bus handle
>  *
>  * Returns 0
>  */
> 
> See also Documentation/kernel-doc-nano-HOWTO.txt
> 
> > +/**********************************************************************
> > + *  UMALDMA_RX_PROCESS(sc,d,work_to_do,poll)
> > + *
> > + *  Process "completed" receive buffers on the specified DMA channel.
> > + *
> > + *  Input parameters:
> > + *            sc - softc structure
> > + *	       d - DMA channel context
> > + *    work_to_do - no. of packets to process before enabling interrupt
> > + *                 again (for NAPI)
> > + *          poll - 1: using polling (for NAPI)
> > + *
> > + *  Return value:
> > + *	   nothing
> > + ********************************************************************* */
> > +static int umaldma_rx_process(struct umal_softc *sc, struct umaldma *d,
> > +		int work_to_do, int poll)
> 
> It seems that you tried to convert the driver to NAPI but did not succeed,
> as this function is only called from the interrupt handler directly.
> 
> There is usually a significant performance win from using NAPI, so you
> should better try again. If you had problems doing that, please ask
> on netdev.
> 
> > +
> > +#ifdef CONFIG_CMDLINE_FORCE
> > +	eaddr[0] = 0x00;
> > +	eaddr[1] = 0x25;
> > +	eaddr[2] = 0x9b;
> > +	eaddr[3] = 0xff;
> > +	eaddr[4] = 0x00;
> > +	eaddr[5] = 0x00;
> > +#endif
> > +
> > +	for (i = 0; i < 6; i++)
> > +		dev->dev_addr[i] = eaddr[i];
> 
> You can use random_ether_addr() to generate a working unique MAC address
> if the hardware does not provide one.
> 
> 	Arnd
Thanks Arnd.
I will redo this driver.

Guan Xuetao
