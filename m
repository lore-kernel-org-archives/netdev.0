From: Scott Wood <scottwood@freescale.com>
Subject: Re: [v2,5/9] fsl/fman: Add Frame Manager support
Date: Thu, 2 Jul 2015 15:17:08 -0500
Message-ID: <1435868228.9432.95.camel@freescale.com>
References: <1435174555-7008-1-git-send-email-igal.liberman@freescale.com>
	 <1435290885.6524.13.camel@freescale.com>
	 <DM2PR03MB3837D90A0A4A1BE054CFB35E6970@DM2PR03MB383.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"Bucur Madalin-Cristian-B32716" <madalin.bucur@freescale.com>,
	"pebolle@tiscali.nl" <pebolle@tiscali.nl>
To: Liberman Igal-B31950 <Igal.Liberman@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0143.outbound.protection.outlook.com ([157.56.110.143]:1187
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754292AbbGBURe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jul 2015 16:17:34 -0400
In-Reply-To: <DM2PR03MB3837D90A0A4A1BE054CFB35E6970@DM2PR03MB383.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-07-02 at 10:32 -0500, Liberman Igal-B31950 wrote:
> Hi Scott,
> Thank you for your feedback, please take a look at my comments/questions.
> 
> Regards,
> Igal Liberman.
> 
> > -----Original Message-----
> > From: Wood Scott-B07421
> > Sent: Friday, June 26, 2015 6:55 AM
> > To: Liberman Igal-B31950
> > Cc: netdev@vger.kernel.org; linuxppc-dev@lists.ozlabs.org; Bucur Madalin-
> > Cristian-B32716; pebolle@tiscali.nl
> > Subject: Re: [v2,5/9] fsl/fman: Add Frame Manager support
> > 
> > On Wed, 2015-06-24 at 22:35 +0300,  igal.liberman@freescale.comwrote:
> > > From: Igal Liberman <Igal.Liberman@freescale.com>
> > > 
> > > Add Frame Manger Driver support.
> > > This patch adds The FMan configuration, initialization and runtime
> > > control routines.
> > > 
> > > Signed-off-by: Igal Liberman <Igal.Liberman@freescale.com>
> > > ---
> > >  drivers/net/ethernet/freescale/fman/Kconfig        |   35 +
> > >  drivers/net/ethernet/freescale/fman/Makefile       |    2 +-
> > >  drivers/net/ethernet/freescale/fman/fm.c           | 1406
> > > ++++++++++++++++++++
> > >  drivers/net/ethernet/freescale/fman/fm.h           |  394 ++++++
> > >  drivers/net/ethernet/freescale/fman/fm_common.h    |  142 ++
> > >  drivers/net/ethernet/freescale/fman/fm_drv.c       |  701 ++++++++++
> > >  drivers/net/ethernet/freescale/fman/fm_drv.h       |  116 ++
> > >  drivers/net/ethernet/freescale/fman/inc/enet_ext.h |  199 +++
> > >  drivers/net/ethernet/freescale/fman/inc/fm_ext.h   |  488 +++++++
> > >  .../net/ethernet/freescale/fman/inc/fsl_fman_drv.h |   99 ++
> > >  drivers/net/ethernet/freescale/fman/inc/service.h  |   55 +
> > >  11 files changed, 3636 insertions(+), 1 deletion(-)  create mode
> > > 100644 drivers/net/ethernet/freescale/fman/fm.c
> > >  create mode 100644 drivers/net/ethernet/freescale/fman/fm.h
> > >  create mode 100644 drivers/net/ethernet/freescale/fman/fm_common.h
> > >  create mode 100644 drivers/net/ethernet/freescale/fman/fm_drv.c
> > >  create mode 100644 drivers/net/ethernet/freescale/fman/fm_drv.h
> > >  create mode 100644 drivers/net/ethernet/freescale/fman/inc/enet_ext.h
> > >  create mode 100644 drivers/net/ethernet/freescale/fman/inc/fm_ext.h
> > >  create mode 100644
> > > drivers/net/ethernet/freescale/fman/inc/fsl_fman_drv.h
> > >  create mode 100644 drivers/net/ethernet/freescale/fman/inc/service.h
> > 
> > Again, please start with something pared down, without extraneous
> > features, but *with* enough functionality to actually pass packets around.
> > Getting this thing into decent shape is going to be hard enough without
> > carrying around the excess baggage.
> > 
> > > diff --git a/drivers/net/ethernet/freescale/fman/Kconfig
> > > b/drivers/net/ethernet/freescale/fman/Kconfig
> > > index 825a0d5..12c75bfd 100644
> > > --- a/drivers/net/ethernet/freescale/fman/Kconfig
> > > +++ b/drivers/net/ethernet/freescale/fman/Kconfig
> > > @@ -7,3 +7,38 @@ config FSL_FMAN
> > >               Freescale Data-Path Acceleration Architecture Frame 
> > > Manager
> > >               (FMan) support
> > > 
> > > +if FSL_FMAN
> > > +
> > > +config FSL_FM_MAX_FRAME_SIZE
> > > +     int "Maximum L2 frame size"
> > > +     range 64 9600
> > > +     default "1522"
> > > +     help
> > > +             Configure this in relation to the maximum possible MTU of 
> > > your
> > > +             network configuration. In particular, one would need to
> > > +             increase this value in order to use jumbo frames.
> > > +             FSL_FM_MAX_FRAME_SIZE must accommodate the Ethernet FCS
> > > +             (4 bytes) and one ETH+VLAN header (18 bytes), to a total 
> > > of
> > > +             22 bytes in excess of the desired L3 MTU.
> > > +
> > > +             Note that having too large a FSL_FM_MAX_FRAME_SIZE (much
> > larger
> > > +             than the actual MTU) may lead to buffer exhaustion, 
> > > especially
> > > +             in the case of badly fragmented datagrams on the Rx path.
> > > +             Conversely, having a FSL_FM_MAX_FRAME_SIZE smaller than 
> > > the
> > > +             actual MTU will lead to frames being dropped.
> > 
> > Scatter gather can't be used for jumbo frames?
> > 
> 
> Scatter gather is used, it's introduced in dpaa_eth as a separate patch 
> from the basic support.
> The dpaa_eth can work in S/G mode or use large buffers, max frame size 
> sized to reduce S/G overhead (performance vs memory used trade-off).

That's not what the help text says: "In particular, one would need to
increase this value in order to use jumbo frames" and "Conversely, having a 
FSL_FM_MAX_FRAME_SIZE smaller than the actual MTU will lead to frames being 
dropped."

> > Why is this a compile-time option?
> > 
> 
> This is needed for a couple of reasons:
>  - FMan resource sizing - we need to know the maximum frame size we plan to 
> use for determining the Rx FIFO sizes at config time

Why can't the FIFO be resized at runtime?

>  - There are issues when changing the MAC maximum frame size at runtime 
> thus the need to set in HW the maximum allowable and compensate from sw 
> (drop frames above the set MTU).

What are the issues?

In any case, it could at least be a module parameter (i.e. a kernel command 
line argument when not built as a module), rather than a compile-time option.

> > > +
> > > +config FSL_FM_RX_EXTRA_HEADROOM
> > > +     int "Add extra headroom at beginning of data buffers"
> > > +     range 16 384
> > > +     default "64"
> > > +     help
> > > +             Configure this to tell the Frame Manager to reserve some 
> > > extra
> > > +             space at the beginning of a data buffer on the receive 
> > > path,
> > > +             before Internal Context fields are copied. This is in 
> > > addition
> > > +             to the private data area already reserved for driver 
> > > internal
> > > +             use. The provided value must be a multiple of 16.
> > > +
> > > +             This option does not affect in any way the layout of
> > > +             transmitted buffers.
> > 
> > There's nothing here to indicate when a user would want to do this.
> > 
> > Why is this a compile-time option?
> > 
> 
> This allows reserving some more space at the start of the skb and may avoid 
> the need for a skb_realloc_headroom().

That doesn't tell an end-user when they would want to change this.

> > > +     } else {
> > > +             /* Reset the FM if required. */
> > > +             if (p_fm->reset_on_init) {
> > > +                     u32 svr = mfspr(SPRN_SVR);
> > > +
> > > +                     if (((SVR_SOC_VER(svr) == SVR_T4240 &&
> > > +                           SVR_REV(svr) > 0x10)) ||
> > > +                             ((SVR_SOC_VER(svr) == SVR_T4160 &&
> > > +                               SVR_REV(svr) > 0x10)) ||
> > > +                             ((SVR_SOC_VER(svr) == SVR_T4080 &&
> > > +                               SVR_REV(svr) > 0x10)) ||
> > > +                             (SVR_SOC_VER(svr) == SVR_T2080) ||
> > > +                             (SVR_SOC_VER(svr) == SVR_T2081)) {
> > > +                             pr_debug("Hack: No FM reset!\n");
> >                 if (IS_ERR_VALUE(p_fm->cam_offset)) { Why?
> > 
> 
> fm_muram_alloc () can return an offset or an Error.

No, I mean why "Hack: No FM reset!"?


> > > +                             fman_resume(p_fm->p_fm_fpm_regs);
> > > +                             usleep_range(100, 101);
> > > +                     }
> > > +             }
> > > +
> > 
> > Why such a narrow range in usleep_range()?
> > 
> 
> I was looking here: > 
> > Ihttps://www.kernel.org/doc/Documentation/timers/timers-howto.ttn addition, 
> > checkpatch says that usleep_range is preferred over udelay.
> So instead of udelay(100), I used usleep_range(100, 101);
> We can change the range, in your opinion, what is the more appropriate 
> range?
> 

"The larger a range you supply, the greater a chance that you will not 
trigger an interrupt; this should be balanced with what is an acceptable 
upper bound on delay / performance for your specific code path. Exact 
tolerances here are very situation specific, thus it is left to the caller to 
determine a reasonable range."

A spread of only 1us is pretty much useless, and for the shorter delays (e.g. 
10us) just use udelay().

> > > +/* do not change! if changed, must be disabled for rev1 ! */
> > > +#define DFLT_VERIFY_UCODE                 false
> > 
> > I know I complained about this last time...
> > 
> > 
> 
> Leftovers, removed.

Please also check for any leftovers I didn't spot, throughout the patchset.

> 
> > > +
> > > +#define DFLT_DMA_READ_INT_BUF_LOW(dma_thresh_max_buf)        \
> > > +     ((dma_thresh_max_buf + 1) / 2)
> > > +#define DFLT_DMA_READ_INT_BUF_HIGH(dma_thresh_max_buf)       \
> > > +     ((dma_thresh_max_buf + 1) * 3 / 4)
> > > +#define DFLT_DMA_WRITE_INT_BUF_LOW(dma_thresh_max_buf)       \
> > > +     ((dma_thresh_max_buf + 1) / 2)
> > > +#define DFLT_DMA_WRITE_INT_BUF_HIGH(dma_thresh_max_buf)\
> > > +     ((dma_thresh_max_buf + 1) * 3 / 4)
> > > +#define DFLT_DMA_COMM_Q_LOW(major, dma_thresh_max_commq)
> > \
> > > +     ((major == 6) ? 0x2A : ((dma_thresh_max_commq + 1) / 2))
> > > +#define DFLT_DMA_COMM_Q_HIGH(major, dma_thresh_max_commq)
> > \
> > > +     ((major == 6) ? 0x3f : ((dma_thresh_max_commq + 1) * 3 / 4))
> > > +#define DFLT_TOTAL_NUM_OF_TASKS(major, minor,
> > bmi_max_num_of_tasks)  \
> > > +     ((major == 6) ? ((minor == 1 || minor == 4) ? 59 : 124) :       \
> > > +     bmi_max_num_of_tasks)
> > 
> > Where do 0x2a, 0x3f, 59, 124, etc come from?  Please define symbolically.
> > 
> 
> Added defines for the values above.

Please also check the entire patchset for similar magic numbers.

> > > +#define DFLT_TOTAL_FIFO_SIZE(major, minor)                   \
> > > +     ((major == 6) ?                                         \
> > > +     ((minor == 1 || minor == 4) ? (156 * 1024) : (295 * 1024)) :    \
> > > +     (((major == 2) || (major == 5)) ?                       \
> > > +     (100 * 1024) : ((major == 4) ?                  \
> > > +     (46 * 1024) : (122 * 1024))))
> > 
> > This isn't the International Obfuscated C Code Contest.
> > 
> 
> Made it look slightly better.
> Given the large number of HW platforms supported, this selection will look 
> complicated as much as we try to beautify it.
> This code determines the KB of MURAM to use as total FIFO size based on 
> FMan revision.

static inline int fm_default_total_fifo_size(int major, int minor)
{
        switch (major) {
        case 2:
        case 5:
                return 100 * 1024;
        case 4:
                return 46 * 1024;
        case 6:
                if (minor == 1 || minor == 4)
                        return 156 * 1024;
                return 295 * 1024;
        default:
                return 122 * 1024;
        }
}

A comment explaining how these values are chosen and what the relevant 
difference in the FMan versions is, would also be helpful.

> > > 
> > > +/* Memory Mapped Registers */
> > > +
> > > +struct fm_iram_regs_t {
> > > +     uint32_t iadd;  /* FM IRAM instruction address register */
> > > +     uint32_t idata;/* FM IRAM instruction data register */
> > > +     uint32_t itcfg;/* FM IRAM timing config register */
> > > +     uint32_t iready;/* FM IRAM ready register */
> > > +     uint8_t res[0x80000 - 0x10];
> > > +} __attribute__((__packed__));
> > 
> > Why do you need __packed__ on this?
> > 
> 
> As all but the last the member of this memory mapped struct are u32, it's 
> not mandatory but at a certain moment someone considered a good idea to 
> throw in the packed attribute.
> I you prefer to remove it, II can do so.

I prever removing it.

> > Why do you need the padding on the end?     
> 
> Again, it is memory mapped, we don't have other regs after those, so we can 
> drop the padding, I can remove it.
> I you prefer to remove it, II can do so.

Likewise.

> > > 
> > > +/* Extra headroom for Rx buffers.
> > > + * FMan is instructed to allocate, on the Rx path, this amount of
> > > + * space at the beginning of a data buffer, beside the DPA private
> > > + * data area and the IC fields.
> > > + * Does not impact Tx buffer layout.
> > > + * Configurable from Kconfig or bootargs. Zero by default, it's
> > > +needed on
> > > + * particular forwarding scenarios that add extra headers to the
> > > + * forwarded frame.
> > > + */
> > > +int fsl_fm_rx_extra_headroom =
> > CONFIG_FSL_FM_RX_EXTRA_HEADROOM;
> > 
> > If it's configurable via bootargs, why is the kconfig needed?
> > 
> 
> KConfig sets default value, in bootargs you can override.

Why can't the default just be hardcoded, and have only bootargs to override?

> > > +/* Define ASSERT condition */
> > > +#undef ASSERT
> > > +#define ASSERT(x)       WARN_ON(!(x))
> > 
> > Why not just use WARN_ON directly?
> > 
> 
> Mostly personal preference, I've also seen similar constructs used in other 
> drivers.
> One can decide later to change this to BUG_ON() or disable it for debug 
> purposes.

...and with that undef you end up with behavior that might depend on the 
order in which you include headers. :-P

Why is it so important to be able to change it?

-Scott
