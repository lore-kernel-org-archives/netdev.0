From: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Subject: Re: [PATCH 11/12] ptp: Added a clock driver for the IXP46x.
Date: Tue, 15 Jun 2010 12:41:56 -0600
Message-ID: <AANLkTinPDaWNvUG8q8RdvRUga-qrPlSV2H5TkzVVMaFn@mail.gmail.com>
References: <cover.1276615626.git.richard.cochran@omicron.at>
	<0c03ef3e283c6b3ef58feaf1f77ccb0fd605010b.1276615626.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <0c03ef3e283c6b3ef58feaf1f77ccb0fd605010b.1276615626.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 15, 2010 at 10:10 AM, Richard Cochran
<richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> This patch adds a driver for the hardware time stamping unit found on the
> IXP465. Only the basic clock operations are implemented.
>
> Signed-off-by: Richard Cochran <richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>

Hi Richard,

Comments below...

> ---
> =A0arch/arm/mach-ixp4xx/include/mach/ixp46x_ts.h | =A0 67 +++++++
> =A0drivers/net/arm/ixp4xx_eth.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A01=
94 +++++++++++++++++++++
> =A0drivers/ptp/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 | =A0 13 ++
> =A0drivers/ptp/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0| =A0 =A01 +
> =A0drivers/ptp/ptp_ixp46x.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =
=A0231 +++++++++++++++++++++++++
> =A05 files changed, 506 insertions(+), 0 deletions(-)
> =A0create mode 100644 arch/arm/mach-ixp4xx/include/mach/ixp46x_ts.h
> =A0create mode 100644 drivers/ptp/ptp_ixp46x.c
>
> diff --git a/arch/arm/mach-ixp4xx/include/mach/ixp46x_ts.h b/arch/arm/mac=
h-ixp4xx/include/mach/ixp46x_ts.h
> new file mode 100644
> index 0000000..7fb02b6
> --- /dev/null
> +++ b/arch/arm/mach-ixp4xx/include/mach/ixp46x_ts.h
> @@ -0,0 +1,67 @@
> +/*
> + * PTP 1588 clock using the IXP46X
> + *
> + * Copyright (C) 2010 OMICRON electronics GmbH
> + *
> + * =A0This program is free software; you can redistribute it and/or modi=
fy
> + * =A0it under the terms of the GNU General Public License as published =
by
> + * =A0the Free Software Foundation; either version 2 of the License, or
> + * =A0(at your option) any later version.
> + *
> + * =A0This program is distributed in the hope that it will be useful,
> + * =A0but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * =A0MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. =A0See the
> + * =A0GNU General Public License for more details.
> + *
> + * =A0You should have received a copy of the GNU General Public License
> + * =A0along with this program; if not, write to the Free Software
> + * =A0Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
> + */
> +
> +#ifndef _IXP46X_TS_H_
> +#define _IXP46X_TS_H_
> +
> +#define DEFAULT_ADDEND 0xF0000029
> +#define TICKS_NS_SHIFT 4
> +
> +struct ixp46x_channel_ctl {
> + =A0 =A0 =A0 u32 Ch_Control; /* 0x40 Time Synchronization Channel Contro=
l */
> + =A0 =A0 =A0 u32 Ch_Event; =A0 /* 0x44 Time Synchronization Channel Even=
t */
> + =A0 =A0 =A0 u32 TxSnapLo; =A0 /* 0x48 Transmit Snapshot Low Register */
> + =A0 =A0 =A0 u32 TxSnapHi; =A0 /* 0x4C Transmit Snapshot High Register */
> + =A0 =A0 =A0 u32 RxSnapLo; =A0 /* 0x50 Receive Snapshot Low Register */
> + =A0 =A0 =A0 u32 RxSnapHi; =A0 /* 0x54 Receive Snapshot High Register */
> + =A0 =A0 =A0 u32 SrcUUIDLo; =A0/* 0x58 Source UUID0 Low Register */
> + =A0 =A0 =A0 u32 SrcUUIDHi; =A0/* 0x5C Sequence Identifier/Source UUID0 =
High */
> +};

Nitpick.  We use all lower case names for structures in Linux.

> +
> +struct ixp46x_ts_regs {
> + =A0 =A0 =A0 u32 Control; =A0 =A0 /* 0x00 Time Sync Control Register */
> + =A0 =A0 =A0 u32 Event; =A0 =A0 =A0 /* 0x04 Time Sync Event Register */
> + =A0 =A0 =A0 u32 Addend; =A0 =A0 =A0/* 0x08 Time Sync Addend Register */
> + =A0 =A0 =A0 u32 Accum; =A0 =A0 =A0 /* 0x0C Time Sync Accumulator Regist=
er */
> + =A0 =A0 =A0 u32 Test; =A0 =A0 =A0 =A0/* 0x10 Time Sync Test Register */
> + =A0 =A0 =A0 u32 Unused; =A0 =A0 =A0/* 0x14 */
> + =A0 =A0 =A0 u32 RSysTime_Lo; /* 0x18 RawSystemTime_Low Register */
> + =A0 =A0 =A0 u32 RSysTimeHi; =A0/* 0x1C RawSystemTime_High Register */
> + =A0 =A0 =A0 u32 SysTimeLo; =A0 /* 0x20 SystemTime_Low Register */
> + =A0 =A0 =A0 u32 SysTimeHi; =A0 /* 0x24 SystemTime_High Register */
> + =A0 =A0 =A0 u32 TrgtLo; =A0 =A0 =A0/* 0x28 TargetTime_Low Register */
> + =A0 =A0 =A0 u32 TrgtHi; =A0 =A0 =A0/* 0x2C TargetTime_High Register */
> + =A0 =A0 =A0 u32 ASMSLo; =A0 =A0 =A0/* 0x30 Auxiliary Slave Mode Snapsho=
t Low =A0*/
> + =A0 =A0 =A0 u32 ASMSHi; =A0 =A0 =A0/* 0x34 Auxiliary Slave Mode Snapsho=
t High */
> + =A0 =A0 =A0 u32 AMMSLo; =A0 =A0 =A0/* 0x38 Auxiliary Master Mode Snapsh=
ot Low */
> + =A0 =A0 =A0 u32 AMMSHi; =A0 =A0 =A0/* 0x3C Auxiliary Master Mode Snapsh=
ot High */
> +
> + =A0 =A0 =A0 struct ixp46x_channel_ctl channel[3];
> +};
> +
> +/* 0x40 Time Synchronization Channel Control Register Bits */
> +#define MASTER_MODE =A0 (1<<0)
> +#define TIMESTAMP_ALL (1<<1)
> +
> +/* 0x44 Time Synchronization Channel Event Register Bits */
> +#define TX_SNAPSHOT_LOCKED (1<<0)
> +#define RX_SNAPSHOT_LOCKED (1<<1)
> +
> +#endif
> diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/arm/ixp4xx_eth.c
> index 4f1cc71..2201960 100644
> --- a/drivers/net/arm/ixp4xx_eth.c
> +++ b/drivers/net/arm/ixp4xx_eth.c
> @@ -30,9 +30,12 @@
> =A0#include <linux/etherdevice.h>
> =A0#include <linux/io.h>
> =A0#include <linux/kernel.h>
> +#include <linux/net_tstamp.h>
> =A0#include <linux/phy.h>
> =A0#include <linux/platform_device.h>
> +#include <linux/ptp_classify.h>
> =A0#include <linux/slab.h>
> +#include <mach/ixp46x_ts.h>
> =A0#include <mach/npe.h>
> =A0#include <mach/qmgr.h>
>
> @@ -67,6 +70,14 @@
> =A0#define RXFREE_QUEUE(port_id) =A0(NPE_ID(port_id) + 26)
> =A0#define TXDONE_QUEUE =A0 =A0 =A0 =A0 =A0 31
>
> +#define PTP_SLAVE_MODE =A0 =A0 =A0 =A0 1
> +#define PTP_MASTER_MODE =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A02
> +#define PORT2CHANNEL(p) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A01
> +/*
> + * PHYSICAL_ID(p->id) ?
> + * TODO - Figure out correct mapping.
> + */
> +
> =A0/* TX Control Registers */
> =A0#define TX_CNTRL0_TX_EN =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x01
> =A0#define TX_CNTRL0_HALFDUPLEX =A0 0x02
> @@ -171,6 +182,8 @@ struct port {
> =A0 =A0 =A0 =A0int id; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* logical port ID=
 */
> =A0 =A0 =A0 =A0int speed, duplex;
> =A0 =A0 =A0 =A0u8 firmware[4];
> + =A0 =A0 =A0 int hwts_tx_en;
> + =A0 =A0 =A0 int hwts_rx_en;
> =A0};
>
> =A0/* NPE message structure */
> @@ -246,6 +259,170 @@ static int ports_open;
> =A0static struct port *npe_port_tab[MAX_NPES];
> =A0static struct dma_pool *dma_pool;
>
> +static struct sock_filter ptp_filter[] =3D {
> + =A0 =A0 =A0 PTP_FILTER
> +};
> +
> +static int match(struct sk_buff *skb, u16 uid_hi, u32 uid_lo, u16 seq)
> +{
> + =A0 =A0 =A0 unsigned int type;
> + =A0 =A0 =A0 u16 *hi, *id;
> + =A0 =A0 =A0 u8 *lo, *data =3D skb->data;
> +
> + =A0 =A0 =A0 type =3D sk_run_filter(skb, ptp_filter, ARRAY_SIZE(ptp_filt=
er));
> +
> + =A0 =A0 =A0 if (PTP_CLASS_V1_IPV4 =3D=3D type) {
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 id =3D (u16 *)(data + 42 + 30);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 hi =3D (u16 *)(data + 42 + 22);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lo =3D data + 42 + 24;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return (uid_hi =3D=3D *hi &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 =3D=3D memcmp(&uid_lo, lo=
, sizeof(uid_lo)) &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 seq =3D=3D *id);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static void do_rx_timestamp(struct port *port, struct sk_buff *skb)
> +{
> + =A0 =A0 =A0 struct skb_shared_hwtstamps *shhwtstamps;
> + =A0 =A0 =A0 struct ixp46x_ts_regs *regs;
> + =A0 =A0 =A0 u64 ns;
> + =A0 =A0 =A0 u32 ch, hi, lo, val;
> + =A0 =A0 =A0 u16 uid, seq;
> +
> + =A0 =A0 =A0 if (!port->hwts_rx_en)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 ch =3D PORT2CHANNEL(port);
> +
> + =A0 =A0 =A0 regs =3D (struct ixp46x_ts_regs __iomem *) IXP4XX_TIMESYNC_=
BASE_VIRT;
> +
> + =A0 =A0 =A0 val =3D __raw_readl(&regs->channel[ch].Ch_Event);
> +
> + =A0 =A0 =A0 if (!(val & RX_SNAPSHOT_LOCKED))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 lo =3D __raw_readl(&regs->channel[ch].SrcUUIDLo);
> + =A0 =A0 =A0 hi =3D __raw_readl(&regs->channel[ch].SrcUUIDHi);
> +
> + =A0 =A0 =A0 uid =3D hi & 0xffff;
> + =A0 =A0 =A0 seq =3D (hi >> 16) & 0xffff;
> +
> + =A0 =A0 =A0 if (!match(skb, htons(uid), htonl(lo), htons(seq)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> +
> + =A0 =A0 =A0 lo =3D __raw_readl(&regs->channel[ch].RxSnapLo);
> + =A0 =A0 =A0 hi =3D __raw_readl(&regs->channel[ch].RxSnapHi);
> + =A0 =A0 =A0 ns =3D ((u64) hi) << 32;
> + =A0 =A0 =A0 ns |=3D lo;
> + =A0 =A0 =A0 ns <<=3D TICKS_NS_SHIFT;
> +
> + =A0 =A0 =A0 shhwtstamps =3D skb_hwtstamps(skb);
> + =A0 =A0 =A0 memset(shhwtstamps, 0, sizeof(*shhwtstamps));
> + =A0 =A0 =A0 shhwtstamps->hwtstamp =3D ns_to_ktime(ns);
> +out:
> + =A0 =A0 =A0 __raw_writel(RX_SNAPSHOT_LOCKED, &regs->channel[ch].Ch_Even=
t);
> +}
> +
> +static void do_tx_timestamp(struct port *port, struct sk_buff *skb)
> +{
> +#ifdef __ARMEB__
> + =A0 =A0 =A0 struct skb_shared_hwtstamps shhwtstamps;
> + =A0 =A0 =A0 struct ixp46x_ts_regs *regs;
> + =A0 =A0 =A0 union skb_shared_tx *shtx;
> + =A0 =A0 =A0 u64 ns;
> + =A0 =A0 =A0 u32 ch, cnt, hi, lo, val;
> +
> + =A0 =A0 =A0 shtx =3D skb_tx(skb);
> +
> + =A0 =A0 =A0 if (!shtx->in_progress)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 ch =3D PORT2CHANNEL(port);
> +
> + =A0 =A0 =A0 regs =3D (struct ixp46x_ts_regs __iomem *) IXP4XX_TIMESYNC_=
BASE_VIRT;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* This really stinks, but we have to poll for the Tx tim=
e stamp.
> + =A0 =A0 =A0 =A0* Usually, the time stamp is ready after 4 to 6 microsec=
onds.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 for (cnt =3D 0; cnt < 100; cnt++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 val =3D __raw_readl(&regs->channel[ch].Ch_E=
vent);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (val & TX_SNAPSHOT_LOCKED)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 udelay(1);

You want to get stuff as fast as possible, but there is a udelay()
that just chews up CPU time.  Would cpu_relax() be sufficient with a
time-based exit condition in the loop?

> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 if (!(val & TX_SNAPSHOT_LOCKED)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 shtx->in_progress =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 lo =3D __raw_readl(&regs->channel[ch].TxSnapLo);
> + =A0 =A0 =A0 hi =3D __raw_readl(&regs->channel[ch].TxSnapHi);
> + =A0 =A0 =A0 ns =3D ((u64) hi) << 32;
> + =A0 =A0 =A0 ns |=3D lo;
> + =A0 =A0 =A0 ns <<=3D TICKS_NS_SHIFT;
> +
> + =A0 =A0 =A0 memset(&shhwtstamps, 0, sizeof(shhwtstamps));
> + =A0 =A0 =A0 shhwtstamps.hwtstamp =3D ns_to_ktime(ns);
> + =A0 =A0 =A0 skb_tstamp_tx(skb, &shhwtstamps);
> +
> + =A0 =A0 =A0 __raw_writel(TX_SNAPSHOT_LOCKED, &regs->channel[ch].Ch_Even=
t);
> +#endif
> +}
> +
> +static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr, =
int cmd)
> +{
> + =A0 =A0 =A0 struct hwtstamp_config cfg;
> + =A0 =A0 =A0 struct ixp46x_ts_regs *regs;
> + =A0 =A0 =A0 struct port *port =3D netdev_priv(netdev);
> + =A0 =A0 =A0 int ch;
> +
> + =A0 =A0 =A0 if (copy_from_user(&cfg, ifr->ifr_data, sizeof(cfg)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EFAULT;
> +
> + =A0 =A0 =A0 if (cfg.flags) /* reserved for future extensions */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> +
> + =A0 =A0 =A0 ch =3D PORT2CHANNEL(port);
> + =A0 =A0 =A0 regs =3D (struct ixp46x_ts_regs __iomem *) IXP4XX_TIMESYNC_=
BASE_VIRT;
> +
> + =A0 =A0 =A0 switch (cfg.tx_type) {
> + =A0 =A0 =A0 case HWTSTAMP_TX_OFF:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 port->hwts_tx_en =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 case HWTSTAMP_TX_ON:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 port->hwts_tx_en =3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 default:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ERANGE;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 switch (cfg.rx_filter) {
> + =A0 =A0 =A0 case HWTSTAMP_FILTER_NONE:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 port->hwts_rx_en =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 port->hwts_rx_en =3D PTP_SLAVE_MODE;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __raw_writel(0, &regs->channel[ch].Ch_Contr=
ol);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 port->hwts_rx_en =3D PTP_MASTER_MODE;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __raw_writel(MASTER_MODE, &regs->channel[ch=
].Ch_Control);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 default:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ERANGE;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Clear out any old time stamps. */
> + =A0 =A0 =A0 __raw_writel(TX_SNAPSHOT_LOCKED | RX_SNAPSHOT_LOCKED,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&regs->channel[ch].Ch_Event);
> +
> + =A0 =A0 =A0 return copy_to_user(ifr->ifr_data, &cfg, sizeof(cfg)) ? -EF=
AULT : 0;
> +}
>
> =A0static int ixp4xx_mdio_cmd(struct mii_bus *bus, int phy_id, int locati=
on,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int write, u16 cmd)
> @@ -573,6 +750,7 @@ static int eth_poll(struct napi_struct *napi, int bud=
get)
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0debug_pkt(dev, "eth_poll", skb->data, skb-=
>len);
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_rx_timestamp(port, skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb->protocol =3D eth_type_trans(skb, dev);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->stats.rx_packets++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->stats.rx_bytes +=3D skb->len;
> @@ -652,6 +830,7 @@ static int eth_xmit(struct sk_buff *skb, struct net_d=
evice *dev)
> =A0 =A0 =A0 =A0void *mem;
> =A0 =A0 =A0 =A0u32 phys;
> =A0 =A0 =A0 =A0struct desc *desc;
> + =A0 =A0 =A0 union skb_shared_tx *shtx;
>
> =A0#if DEBUG_TX
> =A0 =A0 =A0 =A0printk(KERN_DEBUG "%s: eth_xmit\n", dev->name);
> @@ -665,6 +844,10 @@ static int eth_xmit(struct sk_buff *skb, struct net_=
device *dev)
>
> =A0 =A0 =A0 =A0debug_pkt(dev, "eth_xmit", skb->data, skb->len);
>
> + =A0 =A0 =A0 shtx =3D skb_tx(skb);
> + =A0 =A0 =A0 if (unlikely(shtx->hardware && port->hwts_tx_en))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 shtx->in_progress =3D 1;
> +
> =A0 =A0 =A0 =A0len =3D skb->len;
> =A0#ifdef __ARMEB__
> =A0 =A0 =A0 =A0offset =3D 0; /* no need to keep alignment */
> @@ -728,6 +911,9 @@ static int eth_xmit(struct sk_buff *skb, struct net_d=
evice *dev)
> =A0#if DEBUG_TX
> =A0 =A0 =A0 =A0printk(KERN_DEBUG "%s: eth_xmit end\n", dev->name);
> =A0#endif
> +
> + =A0 =A0 =A0 do_tx_timestamp(port, skb);
> +
> =A0 =A0 =A0 =A0return NETDEV_TX_OK;
> =A0}
>
> @@ -783,6 +969,9 @@ static int eth_ioctl(struct net_device *dev, struct i=
freq *req, int cmd)
> =A0 =A0 =A0 =A0if (!netif_running(dev))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
>
> + =A0 =A0 =A0 if (cpu_is_ixp46x() && cmd =3D=3D SIOCSHWTSTAMP)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return hwtstamp_ioctl(dev, req, cmd);
> +
> =A0 =A0 =A0 =A0return phy_mii_ioctl(port->phydev, req, cmd);
> =A0}
>
> @@ -1171,6 +1360,11 @@ static int __devinit eth_init_one(struct platform_=
device *pdev)
> =A0 =A0 =A0 =A0char phy_id[MII_BUS_ID_SIZE + 3];
> =A0 =A0 =A0 =A0int err;
>
> + =A0 =A0 =A0 if (sk_chk_filter(ptp_filter, ARRAY_SIZE(ptp_filter))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err("ixp4xx_eth: bad ptp filter\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0if (!(dev =3D alloc_etherdev(sizeof(struct port))))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
>
> diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
> index 3b7bd73..9fb35f6 100644
> --- a/drivers/ptp/Kconfig
> +++ b/drivers/ptp/Kconfig
> @@ -48,4 +48,17 @@ config PTP_1588_CLOCK_GIANFAR
> =A0 =A0 =A0 =A0 =A0To compile this driver as a module, choose M here: the=
 module
> =A0 =A0 =A0 =A0 =A0will be called gianfar_ptp.
>
> +config PTP_1588_CLOCK_IXP46X
> + =A0 =A0 =A0 tristate "Intel IXP46x as PTP clock"
> + =A0 =A0 =A0 depends on PTP_1588_CLOCK
> + =A0 =A0 =A0 depends on IXP4XX_ETH
> + =A0 =A0 =A0 help
> + =A0 =A0 =A0 =A0 This driver adds support for using the IXP46X as a PTP
> + =A0 =A0 =A0 =A0 clock. This clock is only useful if your PTP programs a=
re
> + =A0 =A0 =A0 =A0 getting hardware time stamps on the PTP Ethernet packets
> + =A0 =A0 =A0 =A0 using the SO_TIMESTAMPING API.
> +
> + =A0 =A0 =A0 =A0 To compile this driver as a module, choose M here: the =
module
> + =A0 =A0 =A0 =A0 will be called ptp_ixp46x.
> +
> =A0endmenu
> diff --git a/drivers/ptp/Makefile b/drivers/ptp/Makefile
> index 1651d52..5018f58 100644
> --- a/drivers/ptp/Makefile
> +++ b/drivers/ptp/Makefile
> @@ -4,3 +4,4 @@
>
> =A0obj-$(CONFIG_PTP_1588_CLOCK) =A0 =A0 =A0 =A0 =A0 +=3D ptp_clock.o
> =A0obj-$(CONFIG_PTP_1588_CLOCK_LINUX) =A0 =A0 +=3D ptp_linux.o
> +obj-$(CONFIG_PTP_1588_CLOCK_IXP46X) =A0 =A0+=3D ptp_ixp46x.o
> diff --git a/drivers/ptp/ptp_ixp46x.c b/drivers/ptp/ptp_ixp46x.c
> new file mode 100644
> index 0000000..22c5bc3
> --- /dev/null
> +++ b/drivers/ptp/ptp_ixp46x.c
> @@ -0,0 +1,231 @@
> +/*
> + * PTP 1588 clock using the IXP46X
> + *
> + * Copyright (C) 2010 OMICRON electronics GmbH
> + *
> + * =A0This program is free software; you can redistribute it and/or modi=
fy
> + * =A0it under the terms of the GNU General Public License as published =
by
> + * =A0the Free Software Foundation; either version 2 of the License, or
> + * =A0(at your option) any later version.
> + *
> + * =A0This program is distributed in the hope that it will be useful,
> + * =A0but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * =A0MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. =A0See the
> + * =A0GNU General Public License for more details.
> + *
> + * =A0You should have received a copy of the GNU General Public License
> + * =A0along with this program; if not, write to the Free Software
> + * =A0Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
> + */
> +#include <linux/device.h>
> +#include <linux/err.h>
> +#include <linux/init.h>
> +#include <linux/io.h>
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +
> +#include <linux/ptp_clock_kernel.h>
> +#include <mach/ixp46x_ts.h>
> +
> +DEFINE_SPINLOCK(register_lock);
> +
> +/*
> + * Register access functions
> + */
> +
> +static inline u32 ixp_read(volatile unsigned __iomem *addr)
> +{
> + =A0 =A0 =A0 u32 val;
> + =A0 =A0 =A0 val =3D __raw_readl(addr);
> + =A0 =A0 =A0 return val;
> +}

return __raw_readl(addr) perhaps?

> +
> +static inline void ixp_write(volatile unsigned __iomem *addr, u32 val)
> +{
> + =A0 =A0 =A0 __raw_writel(val, addr);
> +}
> +
> +static u64 sys_time_read(struct ixp46x_ts_regs *regs)
> +{
> + =A0 =A0 =A0 u64 ns;
> + =A0 =A0 =A0 u32 lo, hi;
> +
> + =A0 =A0 =A0 lo =3D ixp_read(&regs->SysTimeLo);
> + =A0 =A0 =A0 hi =3D ixp_read(&regs->SysTimeHi);
> +
> + =A0 =A0 =A0 ns =3D ((u64) hi) << 32;
> + =A0 =A0 =A0 ns |=3D lo;
> + =A0 =A0 =A0 ns <<=3D TICKS_NS_SHIFT;
> +
> + =A0 =A0 =A0 return ns;
> +}
> +
> +static void sys_time_write(struct ixp46x_ts_regs *regs, u64 ns)

Should use the ptp_ixp_ prefix on these functions too.

> +{
> + =A0 =A0 =A0 u32 hi, lo;
> +
> + =A0 =A0 =A0 ns >>=3D TICKS_NS_SHIFT;
> + =A0 =A0 =A0 hi =3D ns >> 32;
> + =A0 =A0 =A0 lo =3D ns & 0xffffffff;
> +
> + =A0 =A0 =A0 ixp_write(&regs->SysTimeLo, lo);
> + =A0 =A0 =A0 ixp_write(&regs->SysTimeHi, hi);
> +}
> +
> +/*
> + * PTP clock operations
> + */
> +
> +static int ptp_ixp_adjfreq(void *priv, s32 ppb)
> +{
> + =A0 =A0 =A0 u64 adj;
> + =A0 =A0 =A0 u32 diff, addend;
> + =A0 =A0 =A0 int neg_adj =3D 0;
> + =A0 =A0 =A0 struct ixp46x_ts_regs *regs =3D priv;
> +
> + =A0 =A0 =A0 if (!ppb)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> +
> + =A0 =A0 =A0 if (ppb < 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 neg_adj =3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ppb =3D -ppb;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 addend =3D DEFAULT_ADDEND;
> + =A0 =A0 =A0 adj =3D addend;
> + =A0 =A0 =A0 adj *=3D ppb;
> + =A0 =A0 =A0 diff =3D div_u64(adj, 1000000000ULL);
> +
> + =A0 =A0 =A0 addend =3D neg_adj ? addend - diff : addend + diff;
> +
> + =A0 =A0 =A0 ixp_write(&regs->Addend, addend);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int ptp_ixp_adjtime(void *priv, struct timespec *ts)
> +{
> + =A0 =A0 =A0 s64 delta, now;
> + =A0 =A0 =A0 unsigned long flags;
> + =A0 =A0 =A0 struct ixp46x_ts_regs *regs =3D priv;
> +
> + =A0 =A0 =A0 delta =3D 1000000000LL * ts->tv_sec;
> + =A0 =A0 =A0 delta +=3D ts->tv_nsec;
> +
> + =A0 =A0 =A0 spin_lock_irqsave(&register_lock, flags);
> +
> + =A0 =A0 =A0 now =3D sys_time_read(regs);
> + =A0 =A0 =A0 now +=3D delta;
> + =A0 =A0 =A0 sys_time_write(regs, now);
> +
> + =A0 =A0 =A0 spin_unlock_irqrestore(&register_lock, flags);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int ptp_ixp_gettime(void *priv, struct timespec *ts)
> +{
> + =A0 =A0 =A0 u64 ns;
> + =A0 =A0 =A0 u32 remainder;
> + =A0 =A0 =A0 unsigned long flags;
> + =A0 =A0 =A0 struct ixp46x_ts_regs *regs =3D priv;
> +
> + =A0 =A0 =A0 spin_lock_irqsave(&register_lock, flags);
> +
> + =A0 =A0 =A0 ns =3D sys_time_read(regs);
> +
> + =A0 =A0 =A0 spin_unlock_irqrestore(&register_lock, flags);
> +
> + =A0 =A0 =A0 ts->tv_sec =3D div_u64_rem(ns, 1000000000, &remainder);
> + =A0 =A0 =A0 ts->tv_nsec =3D remainder;
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int ptp_ixp_settime(void *priv, struct timespec *ts)
> +{
> + =A0 =A0 =A0 u64 ns;
> + =A0 =A0 =A0 unsigned long flags;
> + =A0 =A0 =A0 struct ixp46x_ts_regs *regs =3D priv;
> +
> + =A0 =A0 =A0 ns =3D ts->tv_sec * 1000000000ULL;
> + =A0 =A0 =A0 ns +=3D ts->tv_nsec;
> +
> + =A0 =A0 =A0 spin_lock_irqsave(&register_lock, flags);
> +
> + =A0 =A0 =A0 sys_time_write(regs, ns);
> +
> + =A0 =A0 =A0 spin_unlock_irqrestore(&register_lock, flags);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int ptp_ixp_gettimer(void *priv, int index, struct itimerspec *ts)
> +{
> + =A0 =A0 =A0 /* We do not offer any ancillary features at all. */
> + =A0 =A0 =A0 return -EOPNOTSUPP;
> +}
> +
> +static int ptp_ixp_settimer(void *p, int i, int abs, struct itimerspec *=
ts)
> +{
> + =A0 =A0 =A0 /* We do not offer any ancillary features at all. */
> + =A0 =A0 =A0 return -EOPNOTSUPP;
> +}
> +
> +static int ptp_ixp_enable(void *priv, struct ptp_clock_request *rq, int =
on)
> +{
> + =A0 =A0 =A0 /* We do not offer any ancillary features at all. */
> + =A0 =A0 =A0 return -EOPNOTSUPP;
> +}
> +
> +static struct ptp_clock_info ptp_ixp_caps =3D {
> + =A0 =A0 =A0 .owner =A0 =A0 =A0 =A0 =A0=3D THIS_MODULE,
> + =A0 =A0 =A0 .name =A0 =A0 =A0 =A0 =A0 =3D "IXP46X timer",
> + =A0 =A0 =A0 .max_adj =A0 =A0 =A0 =A0=3D 512000,
> + =A0 =A0 =A0 .n_alarm =A0 =A0 =A0 =A0=3D 0,
> + =A0 =A0 =A0 .n_ext_ts =A0 =A0 =A0 =3D 0,
> + =A0 =A0 =A0 .n_per_out =A0 =A0 =A0=3D 0,
> + =A0 =A0 =A0 .pps =A0 =A0 =A0 =A0 =A0 =A0=3D 0,
> + =A0 =A0 =A0 .priv =A0 =A0 =A0 =A0 =A0 =3D NULL,

If the value is '0' or NULL, just leave them out of the structure initializ=
er.

> + =A0 =A0 =A0 .adjfreq =A0 =A0 =A0 =A0=3D ptp_ixp_adjfreq,
> + =A0 =A0 =A0 .adjtime =A0 =A0 =A0 =A0=3D ptp_ixp_adjtime,
> + =A0 =A0 =A0 .gettime =A0 =A0 =A0 =A0=3D ptp_ixp_gettime,
> + =A0 =A0 =A0 .settime =A0 =A0 =A0 =A0=3D ptp_ixp_settime,
> + =A0 =A0 =A0 .gettimer =A0 =A0 =A0 =3D ptp_ixp_gettimer,
> + =A0 =A0 =A0 .settimer =A0 =A0 =A0 =3D ptp_ixp_settimer,
> + =A0 =A0 =A0 .enable =A0 =A0 =A0 =A0 =3D ptp_ixp_enable,
> +};
> +
> +/* module operations */
> +
> +static struct {
> + =A0 =A0 =A0 struct ixp46x_ts_regs *regs;
> + =A0 =A0 =A0 struct ptp_clock *ptp_clock;
> +} ixp_clock;
> +
> +static void __exit ptp_ixp_exit(void)
> +{
> + =A0 =A0 =A0 ptp_clock_unregister(ixp_clock.ptp_clock);
> +}
> +
> +static int __init ptp_ixp_init(void)
> +{
> + =A0 =A0 =A0 ixp_clock.regs =3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (struct ixp46x_ts_regs __iomem *)IXP4XX_TIM=
ESYNC_BASE_VIRT;
> +
> + =A0 =A0 =A0 ptp_ixp_caps.priv =3D ixp_clock.regs;
> +
> + =A0 =A0 =A0 ixp_clock.ptp_clock =3D ptp_clock_register(&ptp_ixp_caps);
> +
> + =A0 =A0 =A0 if (IS_ERR(ixp_clock.ptp_clock))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return PTR_ERR(ixp_clock.ptp_clock);
> +
> + =A0 =A0 =A0 ixp_write(&ixp_clock.regs->Addend, DEFAULT_ADDEND);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +module_init(ptp_ixp_init);
> +module_exit(ptp_ixp_exit);

Keep module_init and module_exit with their respective function declaration=
s.

g.
