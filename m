From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [RFC v2] virtio: add virtio-over-PCI driver
Date: Tue, 14 Apr 2009 14:28:26 -0600
Message-ID: <fa686aa40904141328oa57fb1bsffd0549a52eca90@mail.gmail.com>
References: <20090224000002.GA578@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Jan-Bernd Themann <THEMANN@de.ibm.com>,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Ira Snyder <iws@ovro.caltech.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.233]:14979 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753279AbZDNU2n convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 16:28:43 -0400
In-Reply-To: <20090224000002.GA578@ovro.caltech.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 23, 2009 at 6:00 PM, Ira Snyder <iws@ovro.caltech.edu> wrot=
e:
> This adds support to Linux for using virtio between two computers lin=
ked by
> a PCI interface. This allows the use of virtio_net to create a famili=
ar,
> fast interface for communication. It should be possible to use other =
virtio
> devices in the future, but this has not been tested.

Hey Ira,

I like this a lot.  I need to do much the same thing on one of my
platforms, so I'm going to use your patch as my starting point.  Have
you made many changes since you posted this version of your patch?
I'd like to collaborate on the development and help to get it
mainlined.

In my case I've got an MPC5200 as the 'host' and a Xilinx Virtex
(ppc440) as the 'client'.  I intend set aside a region of the Xilinx
Virtex's memory space for the shared queues.  I'm starting work on it
now, and I'll provide you with feedback and/or patches as I make
progress.

g.

>
> I have implemented guest support for the Freescale MPC8349EMDS board,=
 which
> is capable of running in PCI agent mode (It acts like a PCI card, but=
 is a
> complete computer system, running Linux). The driver is trivial to po=
rt to
> any MPC83xx system.
>
> It was developed to work in a CompactPCI crate of computers, one of w=
hich
> is a standard x86 system (acting as the host) and many PowerPC system=
s
> (acting as guests).
>
> I have only tested this driver with a single board in my system. The =
host
> is a 1066MHz Pentium3-M, and the guest is a 533MHz PowerPC. I am able
> achieve transfer rates of about 150 mbit host->guest and 350 mbit
> guest->host. A few tests showed that using an mtu of 4000 provided mu=
ch
> better results than an mtu of 1500. Using an mtu of 64000 significant=
ly
> dropped performance. The performance is equivalent to my PCINet drive=
r for
> host->guest, and about 20% faster for guest->host transfers.
>
> I have included a short document explaining what I think is the most
> complicated part of the driver: using the DMA engine to transfer data=
=2E I
> hope everything else is readily obvious from the code. Questions are
> welcome.
>
> I will not be able to work on this full time for at least a few weeks=
, so I
> would appreciate actual review of this driver. =A0Nitpicks are fine, =
I just
> won't be able to respond to them quickly.
>
> RFCv1 -> RFCv2:
> =A0* fix major brokenness of host detach_buf()
> =A0* support VIRTIO_NET_F_CSUM
> =A0* support VIRTIO_NET_F_GSO
> =A0* support VIRTIO_NET_F_MRG_RXBUF
> =A0* rewrote DMA transfers to support merged rxbufs
> =A0* added a hack to fix the endianness of virtio_net's metadata
> =A0* lots more performance for guest->host transfers (~40MB/sec)
> =A0* updated documentation
> =A0* allocate 128 feature bits instead of 32
>
> Signed-off-by: Ira W. Snyder <iws@ovro.caltech.edu>
> ---
>
> Yes, the commit message has too much information. This is an RFC afte=
r
> all. I fully expect to have to make changes. In fact, I posting this
> more to "get it out there" than anything else, since I have other tas=
ks
> that need doing.
>
> I'd appreciate a serious review of the design by the people who have
> been pressuring me to use virtio. I'm very happy to answer any questi=
ons
> you have.
>
> Thanks to everyone who gave feedback for RFCv1!
> Ira
>
> =A0Documentation/virtio-over-PCI.txt =A0 =A0 | =A0 60 +
> =A0arch/powerpc/boot/dts/mpc834x_mds.dts | =A0 =A07 +
> =A0drivers/virtio/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 22 +
> =A0drivers/virtio/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +
> =A0drivers/virtio/vop.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0119 +=
+
> =A0drivers/virtio/vop_fsl.c =A0 =A0 =A0 =A0 =A0 =A0 =A0| 2020 +++++++=
++++++++++++++++++++++++++
> =A0drivers/virtio/vop_host.c =A0 =A0 =A0 =A0 =A0 =A0 | 1071 +++++++++=
++++++++
> =A0drivers/virtio/vop_hw.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 80 ++
> =A08 files changed, 3381 insertions(+), 0 deletions(-)
> =A0create mode 100644 Documentation/virtio-over-PCI.txt
> =A0create mode 100644 drivers/virtio/vop.h
> =A0create mode 100644 drivers/virtio/vop_fsl.c
> =A0create mode 100644 drivers/virtio/vop_host.c
> =A0create mode 100644 drivers/virtio/vop_hw.h
>
> diff --git a/Documentation/virtio-over-PCI.txt b/Documentation/virtio=
-over-PCI.txt
> new file mode 100644
> index 0000000..e4520d4
> --- /dev/null
> +++ b/Documentation/virtio-over-PCI.txt
> @@ -0,0 +1,60 @@
> +The implementation of virtio-over-PCI was driven with the following =
goals:
> +* Avoid MMIO reads, try to use only MMIO writes
> +* Use the onboard DMA engine, for speed
> +
> +The implementation also borrows many of the details from the only ot=
her
> +implementation, virtio_ring.
> +
> +It succeeds in avoiding all MMIO reads on the critical paths. I did =
not
> +see any reason to avoid the use of MMIO reads during device probing,=
 since
> +it is not a critical path.
> +
> +=3D=3D=3D Avoiding MMIO reads =3D=3D=3D
> +To avoid MMIO reads, both the host and guest systems have a copy of =
the
> +descriptors. Both sides need to read the descriptors after they have=
 been
> +written, but only the host system writes to them. This allows us to =
keep a
> +local copy for later use.
> +
> +=3D=3D=3D Using the DMA engine =3D=3D=3D
> +This is the only truly complicated part of the system. Since this
> +implementation was designed for use with virtio_net, it may be biase=
d
> +towards virtio_net's usage of the virtio interface.
> +
> +In merged rxbufs mode, the virtio_net driver provides a receive ring=
, which
> +it fills with empty PAGE_SIZE buffers. The DMA code sets up transfer=
s
> +directly from the guest transmit queue to the empty packets in the h=
ost
> +receive queue. Data transfer in the other direction works in a simil=
ar
> +fashion.
> +
> +The guest (PowerPC) system keeps its own local set of descriptors, w=
hich are
> +filled by the virtio add_buf() call. Whenever this happens, the avai=
l ring is
> +changed, and therefore we try to transfer data.
> +
> +The algorithm is essentially as follows:
> +1) Check for an available local or remote entry
> +2) Check that the other side has enough room for the packet
> +3) Transfer the chain, joining small packets and splitting large pac=
kets
> +4) Move the entries to the used rings, but do not update the used in=
dex
> +5) Schedule a DMA callback to happen when the transfer completes
> +6) Start the DMA transfer
> +7) When the DMA finishes, the callback updates the used indices and
> + =A0 triggers any necessary callbacks
> +
> +The algorithm can only handle chains that are to be coalesced togeth=
er. It
> +puts all data sequentially into the PAGE_SIZE buffers exposed by the
> +receiving side, including both the virtio_net header and packet data=
=2E
> +
> +=3D=3D=3D Startup Sequence =3D=3D=3D
> +There are currently problems in the startup sequence between the hos=
t and
> +guest drivers. The current scheme assumes that the guest is up and w=
aiting
> +before the host is ready. I am having a very hard time coming up wit=
h a scheme
> +that is perfectly safe, where either side could win the race and be =
ready
> +first.
> +
> +Even harder is a situation where you would like to use the "network =
device"
> +from your bootloader to tftp a kernel, then boot Linux. In this case=
,
> +Linux has no knowledge of where the device descriptors were before i=
t booted.
> +You'd need to stop and re-start the host driver to make sure it re-i=
nitializes
> +the new descriptor memory after Linux has booted.
> +
> +This is a definite "needs work" item.
> diff --git a/arch/powerpc/boot/dts/mpc834x_mds.dts b/arch/powerpc/boo=
t/dts/mpc834x_mds.dts
> index d9adba0..5c7617d 100644
> --- a/arch/powerpc/boot/dts/mpc834x_mds.dts
> +++ b/arch/powerpc/boot/dts/mpc834x_mds.dts
> @@ -104,6 +104,13 @@
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mode =3D "cpu";
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0};
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 message-unit@8030 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 compatible =3D "fsl,mpc=
8349-mu";
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 reg =3D <0x8030 0xd0>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 interrupts =3D <69 0x8>=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 interrupt-parent =3D <&=
ipic>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 };
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dma@82a8 {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0#address-cells =3D <1>=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0#size-cells =3D <1>;
> diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
> index 3dd6294..efcf56b 100644
> --- a/drivers/virtio/Kconfig
> +++ b/drivers/virtio/Kconfig
> @@ -33,3 +33,25 @@ config VIRTIO_BALLOON
>
> =A0 =A0 =A0 =A0 If unsure, say M.
>
> +config VIRTIO_OVER_PCI_HOST
> + =A0 =A0 =A0 tristate "Virtio-over-PCI Host support (EXPERIMENTAL)"
> + =A0 =A0 =A0 depends on PCI && EXPERIMENTAL
> + =A0 =A0 =A0 select VIRTIO
> + =A0 =A0 =A0 ---help---
> + =A0 =A0 =A0 =A0 This driver provides the host support necessary for=
 using virtio
> + =A0 =A0 =A0 =A0 over the PCI bus with a Freescale MPC8349EMDS evalu=
ation board.
> +
> + =A0 =A0 =A0 =A0 If unsure, say N.
> +
> +config VIRTIO_OVER_PCI_FSL
> + =A0 =A0 =A0 tristate "Virtio-over-PCI Guest support (EXPERIMENTAL)"
> + =A0 =A0 =A0 depends on MPC834x_MDS && EXPERIMENTAL
> + =A0 =A0 =A0 select VIRTIO
> + =A0 =A0 =A0 select DMA_ENGINE
> + =A0 =A0 =A0 select FSL_DMA
> + =A0 =A0 =A0 ---help---
> + =A0 =A0 =A0 =A0 This driver provides the guest support necessary fo=
r using virtio
> + =A0 =A0 =A0 =A0 over the PCI bus.
> +
> + =A0 =A0 =A0 =A0 If unsure, say N.
> +
> diff --git a/drivers/virtio/Makefile b/drivers/virtio/Makefile
> index 6738c44..f31afaa 100644
> --- a/drivers/virtio/Makefile
> +++ b/drivers/virtio/Makefile
> @@ -2,3 +2,5 @@ obj-$(CONFIG_VIRTIO) +=3D virtio.o
> =A0obj-$(CONFIG_VIRTIO_RING) +=3D virtio_ring.o
> =A0obj-$(CONFIG_VIRTIO_PCI) +=3D virtio_pci.o
> =A0obj-$(CONFIG_VIRTIO_BALLOON) +=3D virtio_balloon.o
> +obj-$(CONFIG_VIRTIO_OVER_PCI_HOST) +=3D vop_host.o
> +obj-$(CONFIG_VIRTIO_OVER_PCI_FSL) +=3D vop_fsl.o
> diff --git a/drivers/virtio/vop.h b/drivers/virtio/vop.h
> new file mode 100644
> index 0000000..5f77228
> --- /dev/null
> +++ b/drivers/virtio/vop.h
> @@ -0,0 +1,119 @@
> +/*
> + * Virtio-over-PCI definitions
> + *
> + * Copyright (c) 2009 Ira W. Snyder <iws@ovro.caltech.edu>
> + *
> + * This file is licensed under the terms of the GNU General Public L=
icense
> + * version 2. This program is licensed "as is" without any warranty =
of any
> + * kind, whether express or implied.
> + */
> +
> +#ifndef VOP_H
> +#define VOP_H
> +
> +#include <linux/types.h>
> +
> +/* The number of entries per ring (MUST be a power of two) */
> +#define VOP_RING_SIZE =A0 =A0 =A0 =A0 =A064
> +
> +/* Marks a buffer as continuing via the next field */
> +#define VOP_DESC_F_NEXT =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A01
> +/* Marks a buffer as write-only (otherwise read-only) */
> +#define VOP_DESC_F_WRITE =A0 =A0 =A0 2
> +
> +/* Interrupts should not be generated when adding to avail or used *=
/
> +#define VOP_F_NO_INTERRUPT =A0 =A0 1
> +
> +/* Virtio-over-PCI descriptors: 12 bytes. These can chain together v=
ia "next" */
> +struct vop_desc {
> + =A0 =A0 =A0 /* Address (host physical) */
> + =A0 =A0 =A0 __le32 addr;
> + =A0 =A0 =A0 /* Length (bytes) */
> + =A0 =A0 =A0 __le32 len;
> + =A0 =A0 =A0 /* Flags */
> + =A0 =A0 =A0 __le16 flags;
> + =A0 =A0 =A0 /* Chaining for descriptors */
> + =A0 =A0 =A0 __le16 next;
> +} __attribute__((packed));
> +
> +/* Virtio-over-PCI used descriptor chains: 8 bytes */
> +struct vop_used_elem {
> + =A0 =A0 =A0 /* Start index of used descriptor chain */
> + =A0 =A0 =A0 __le32 id;
> + =A0 =A0 =A0 /* Total length of the descriptor chain which was used =
(written to) */
> + =A0 =A0 =A0 __le32 len;
> +} __attribute__((packed));
> +
> +/* The ring in host memory, only written by the guest */
> +/* NOTE: with VOP_RING_SIZE =3D=3D 64, this is 520 bytes */
> +struct vop_host_ring {
> + =A0 =A0 =A0 /* The flags, so the guest can indicate that it doesn't=
 want
> + =A0 =A0 =A0 =A0* interrupts when things are added to the avail ring=
 */
> + =A0 =A0 =A0 __le16 flags;
> +
> + =A0 =A0 =A0 /* The index, which points at the next slot where a cha=
in index
> + =A0 =A0 =A0 =A0* will be added to the used ring */
> + =A0 =A0 =A0 __le16 used_idx;
> +
> + =A0 =A0 =A0 /* The used ring */
> + =A0 =A0 =A0 struct vop_used_elem used[VOP_RING_SIZE];
> +} __attribute__((packed));
> +
> +/* The ring in guest memory, only written by the host */
> +/* NOTE: with VOP_RING_SIZE =3D=3D 64, this is 904 bytes! */
> +struct vop_guest_ring {
> + =A0 =A0 =A0 /* The descriptors */
> + =A0 =A0 =A0 struct vop_desc desc[VOP_RING_SIZE];
> +
> + =A0 =A0 =A0 /* The flags, so the host can indicate that it doesn't =
want
> + =A0 =A0 =A0 =A0* interrupts when things are added to the used ring =
*/
> + =A0 =A0 =A0 __le16 flags;
> +
> + =A0 =A0 =A0 /* The index, which points at the next slot where a cha=
in index
> + =A0 =A0 =A0 =A0* will be added to the avail ring */
> + =A0 =A0 =A0 __le16 avail_idx;
> +
> + =A0 =A0 =A0 /* The avail ring */
> + =A0 =A0 =A0 __le16 avail[VOP_RING_SIZE];
> +} __attribute__((packed));
> +
> +/*
> + * This is the status structure holding the virtio_device status
> + * as well as the feature bits for this device and the configuration
> + * space.
> + *
> + * NOTE: it is for the LOCAL device. This is the slow path, so
> + * NOTE: the mmio reads won't cause any speed problems
> + */
> +struct vop_status {
> + =A0 =A0 =A0 /* Status bits for the device */
> + =A0 =A0 =A0 __le32 status;
> +
> + =A0 =A0 =A0 /* Feature bits for the device (128 bits) */
> + =A0 =A0 =A0 __le32 features[4];
> +
> + =A0 =A0 =A0 /* Configuration space (different for each device type)=
 */
> + =A0 =A0 =A0 u8 config[1004];
> +
> +} __attribute__((packed));
> +
> +/*
> + * Layout in memory
> + *
> + * |--------------------------|
> + * | 0: local device status =A0 |
> + * |--------------------------|
> + * | 1024: host/guest ring 1 =A0|
> + * |--------------------------|
> + * | 2048: host/guest ring 2 =A0|
> + * |--------------------------|
> + * | 3072: host/guest ring 3 =A0|
> + * |--------------------------|
> + *
> + * Now, you have one of these for each virtio device, and
> + * then you're pretty much set. You can expose 16K of memory
> + * out on the bus (on each side) and have 4 virtio devices,
> + * each with a different type, and 3 virtqueues
> + */
> +
> +#endif /* VOP_H */
> diff --git a/drivers/virtio/vop_fsl.c b/drivers/virtio/vop_fsl.c
> new file mode 100644
> index 0000000..7cb3cdd
> --- /dev/null
> +++ b/drivers/virtio/vop_fsl.c
> @@ -0,0 +1,2020 @@
> +/*
> + * Virtio-over-PCI MPC8349EMDS Guest Driver
> + *
> + * Copyright (c) 2009 Ira W. Snyder <iws@ovro.caltech.edu>
> + *
> + * This file is licensed under the terms of the GNU General Public L=
icense
> + * version 2. This program is licensed "as is" without any warranty =
of any
> + * kind, whether express or implied.
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/init.h>
> +#include <linux/of_platform.h>
> +#include <linux/io.h>
> +#include <linux/dma-mapping.h>
> +#include <linux/virtio.h>
> +#include <linux/virtio_config.h>
> +#include <linux/virtio_net.h>
> +#include <linux/interrupt.h>
> +#include <linux/virtio_net.h>
> +#include <linux/dmaengine.h>
> +#include <linux/workqueue.h>
> +#include <linux/etherdevice.h>
> +
> +/* MPC8349EMDS specific get_immrbase() */
> +#include <sysdev/fsl_soc.h>
> +
> +#include "vop_hw.h"
> +#include "vop.h"
> +
> +/*
> + * These are internal use only versions of the structures that
> + * are exported over PCI by this driver
> + *
> + * They are used internally to keep track of the PowerPC queues so t=
hat
> + * we don't have to keep flipping endianness all the time
> + */
> +struct vop_loc_desc {
> + =A0 =A0 =A0 u32 addr;
> + =A0 =A0 =A0 u32 len;
> + =A0 =A0 =A0 u16 flags;
> + =A0 =A0 =A0 u16 next;
> +};
> +
> +struct vop_loc_avail {
> + =A0 =A0 =A0 u16 index;
> + =A0 =A0 =A0 u16 ring[VOP_RING_SIZE];
> +};
> +
> +struct vop_loc_used_elem {
> + =A0 =A0 =A0 u32 id;
> + =A0 =A0 =A0 u32 len;
> +};
> +
> +struct vop_loc_used {
> + =A0 =A0 =A0 u16 index;
> + =A0 =A0 =A0 struct vop_loc_used_elem ring[VOP_RING_SIZE];
> +};
> +
> +/*
> + * DMA Resolver state information
> + */
> +struct vop_dma_info {
> + =A0 =A0 =A0 struct dma_chan *chan;
> +
> + =A0 =A0 =A0 /* The currently processing avail entry */
> + =A0 =A0 =A0 u16 loc_avail;
> + =A0 =A0 =A0 u16 rem_avail;
> +
> + =A0 =A0 =A0 /* The currently processing used entries */
> + =A0 =A0 =A0 u16 loc_used;
> + =A0 =A0 =A0 u16 rem_used;
> +};
> +
> +struct vop_vq {
> +
> + =A0 =A0 =A0 /* The actual virtqueue itself */
> + =A0 =A0 =A0 struct virtqueue vq;
> + =A0 =A0 =A0 struct device *dev;
> +
> + =A0 =A0 =A0 /* The host ring address */
> + =A0 =A0 =A0 struct vop_host_ring __iomem *host;
> +
> + =A0 =A0 =A0 /* The guest ring address */
> + =A0 =A0 =A0 struct vop_guest_ring *guest;
> +
> + =A0 =A0 =A0 /* Our own memory descriptors */
> + =A0 =A0 =A0 struct vop_loc_desc desc[VOP_RING_SIZE];
> + =A0 =A0 =A0 struct vop_loc_avail avail;
> + =A0 =A0 =A0 struct vop_loc_used used;
> + =A0 =A0 =A0 unsigned int flags;
> +
> + =A0 =A0 =A0 /* Data tokens from add_buf() */
> + =A0 =A0 =A0 void *data[VOP_RING_SIZE];
> +
> + =A0 =A0 =A0 unsigned int num_free; =A0/* number of free descriptors=
 in desc */
> + =A0 =A0 =A0 unsigned int free_head; /* start of the free descriptor=
s in desc */
> + =A0 =A0 =A0 unsigned int num_added; /* number of entries added to d=
esc */
> +
> + =A0 =A0 =A0 u16 loc_last_used; =A0 =A0 =A0/* the last local used en=
try processed */
> + =A0 =A0 =A0 u16 rem_last_used; =A0 =A0 =A0/* the current value of r=
emote used_idx */
> +
> + =A0 =A0 =A0 /* DMA resolver state */
> + =A0 =A0 =A0 struct vop_dma_info dma;
> + =A0 =A0 =A0 struct work_struct work;
> + =A0 =A0 =A0 int (*resolve)(struct vop_vq *vq);
> +
> + =A0 =A0 =A0 void __iomem *immr;
> + =A0 =A0 =A0 int kick_val;
> +};
> +
> +/* Convert from a struct virtqueue to a struct vop_vq */
> +#define to_vop_vq(X) container_of(X, struct vop_vq, vq)
> +
> +/*
> + * This represents a virtio_device for our driver. It follows the me=
mory
> + * layout shown above. It has pointers to all of the host and guest =
memory
> + * areas that we need to access
> + */
> +struct vop_vdev {
> +
> + =A0 =A0 =A0 /* The specific virtio device (console, net, blk) */
> + =A0 =A0 =A0 struct virtio_device vdev;
> +
> + =A0 =A0 =A0 #define VOP_DEVICE_REGISTERED 1
> + =A0 =A0 =A0 int status;
> +
> + =A0 =A0 =A0 /* Start address of local and remote memory */
> + =A0 =A0 =A0 void *loc;
> + =A0 =A0 =A0 void __iomem *rem;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* These are the status, feature, and configuration i=
nformation
> + =A0 =A0 =A0 =A0* for this virtio device. They are exposed in our me=
mory block
> + =A0 =A0 =A0 =A0* starting at offset 0.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 struct vop_status __iomem *host_status;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* These are the status, feature, and configuration i=
nformation
> + =A0 =A0 =A0 =A0* for the guest virtio device. They are exposed in t=
he guest
> + =A0 =A0 =A0 =A0* memory block starting at offset 0.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 struct vop_status *guest_status;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* These are the virtqueues for the virtio driver run=
ning this
> + =A0 =A0 =A0 =A0* device to use. The host portions are exposed in ou=
r memory block
> + =A0 =A0 =A0 =A0* starting at offset 1024. The exposed areas are ali=
gned to 1024 byte
> + =A0 =A0 =A0 =A0* boundaries, so they appear at offets 1024, 2048, a=
nd 3072
> + =A0 =A0 =A0 =A0* respectively.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 struct vop_vq virtqueues[3];
> +};
> +
> +#define to_vop_vdev(X) container_of(X, struct vop_vdev, vdev)
> +
> +struct vop_dev {
> +
> + =A0 =A0 =A0 struct of_device *op;
> + =A0 =A0 =A0 struct device *dev;
> +
> + =A0 =A0 =A0 /* Reset and start */
> + =A0 =A0 =A0 struct mutex mutex;
> + =A0 =A0 =A0 struct work_struct reset_work;
> + =A0 =A0 =A0 struct work_struct start_work;
> +
> + =A0 =A0 =A0 int irq;
> +
> + =A0 =A0 =A0 /* Our board control registers */
> + =A0 =A0 =A0 void __iomem *immr;
> +
> + =A0 =A0 =A0 /* The guest memory, exposed at PCI BAR1 */
> + =A0 =A0 =A0 #define VOP_GUEST_MEM_SIZE 16384
> + =A0 =A0 =A0 void *guest_mem;
> + =A0 =A0 =A0 dma_addr_t guest_mem_addr;
> +
> + =A0 =A0 =A0 /* Host memory, given to us by host in OMR0 */
> + =A0 =A0 =A0 #define VOP_HOST_MEM_SIZE 16384
> + =A0 =A0 =A0 void __iomem *host_mem;
> +
> + =A0 =A0 =A0 /* The virtio devices */
> + =A0 =A0 =A0 struct vop_vdev devices[4];
> + =A0 =A0 =A0 struct dma_chan *chan;
> +};
> +
> +/*
> + * DMA callback information
> + */
> +struct vop_dma_cbinfo {
> + =A0 =A0 =A0 struct vop_vq *vq;
> +
> + =A0 =A0 =A0 /* The amount to increment the used rings */
> + =A0 =A0 =A0 unsigned int loc;
> + =A0 =A0 =A0 unsigned int rem;
> +};
> +
> +static const char driver_name[] =3D "vdev";
> +static struct kmem_cache *dma_cache;
> +
> +/*------------------------------------------------------------------=
----------*/
> +/* Whole-descriptor access helpers =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> +/*------------------------------------------------------------------=
----------*/
> +
> +/*
> + * Return a copy of a local descriptor in native format for easy use
> + * of all fields
> + *
> + * @vq the virtqueue
> + * @idx the descriptor index
> + * @desc pointer to the structure to copy into
> + */
> +static void vop_loc_desc(struct vop_vq *vq, unsigned int idx,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct vop_loc_desc =
*desc)
> +{
> + =A0 =A0 =A0 BUG_ON(idx >=3D VOP_RING_SIZE);
> + =A0 =A0 =A0 BUG_ON(!desc);
> +
> + =A0 =A0 =A0 desc->addr =A0=3D vq->desc[idx].addr;
> + =A0 =A0 =A0 desc->len =A0 =3D vq->desc[idx].len;
> + =A0 =A0 =A0 desc->flags =3D vq->desc[idx].flags;
> + =A0 =A0 =A0 desc->next =A0=3D vq->desc[idx].next;
> +}
> +
> +/*
> + * Return a copy of a remote descriptor in native format for easy us=
e
> + * of all fields
> + *
> + * @vq the virtqueue
> + * @idx the descriptor index
> + * @desc pointer to the structure to copy into
> + */
> +static void vop_rem_desc(struct vop_vq *vq, unsigned int idx,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct vop_loc_desc =
*desc)
> +{
> + =A0 =A0 =A0 BUG_ON(idx >=3D VOP_RING_SIZE);
> + =A0 =A0 =A0 BUG_ON(!desc);
> +
> + =A0 =A0 =A0 desc->addr =A0=3D le32_to_cpu(vq->guest->desc[idx].addr=
);
> + =A0 =A0 =A0 desc->len =A0 =3D le32_to_cpu(vq->guest->desc[idx].len)=
;
> + =A0 =A0 =A0 desc->flags =3D le16_to_cpu(vq->guest->desc[idx].flags)=
;
> + =A0 =A0 =A0 desc->next =A0=3D le16_to_cpu(vq->guest->desc[idx].next=
);
> +}
> +
> +/*------------------------------------------------------------------=
----------*/
> +/* Local descriptor ring access helpers =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> +/*------------------------------------------------------------------=
----------*/
> +
> +static void vop_set_desc_addr(struct vop_vq *vq, unsigned int idx, u=
32 addr)
> +{
> + =A0 =A0 =A0 vq->desc[idx].addr =3D addr;
> +}
> +
> +static void vop_set_desc_len(struct vop_vq *vq, unsigned int idx, u3=
2 len)
> +{
> + =A0 =A0 =A0 vq->desc[idx].len =3D len;
> +}
> +
> +static void vop_set_desc_flags(struct vop_vq *vq, unsigned int idx, =
u16 flags)
> +{
> + =A0 =A0 =A0 vq->desc[idx].flags =3D flags;
> +}
> +
> +static void vop_set_desc_next(struct vop_vq *vq, unsigned int idx, u=
16 next)
> +{
> + =A0 =A0 =A0 vq->desc[idx].next =3D next;
> +}
> +
> +static u16 vop_get_desc_flags(struct vop_vq *vq, unsigned int idx)
> +{
> + =A0 =A0 =A0 return vq->desc[idx].flags;
> +}
> +
> +static u16 vop_get_desc_next(struct vop_vq *vq, unsigned int idx)
> +{
> + =A0 =A0 =A0 return vq->desc[idx].next;
> +}
> +
> +/*------------------------------------------------------------------=
----------*/
> +/* Status Helpers =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> +/*------------------------------------------------------------------=
----------*/
> +
> +static u32 vop_get_host_status(struct vop_vdev *vdev)
> +{
> + =A0 =A0 =A0 return ioread32(&vdev->host_status->status);
> +}
> +
> +static u32 vop_get_host_features(struct vop_vdev *vdev)
> +{
> + =A0 =A0 =A0 return ioread32(&vdev->host_status->features[0]);
> +}
> +
> +static u16 vop_get_host_flags(struct vop_vq *vq)
> +{
> + =A0 =A0 =A0 return le16_to_cpu(vq->guest->flags);
> +}
> +
> +/*
> + * Set the guest's flags variable (lives in host memory)
> + */
> +static void vop_set_guest_flags(struct vop_vq *vq, u16 flags)
> +{
> + =A0 =A0 =A0 iowrite16(flags, &vq->host->flags);
> +}
> +
> +/*------------------------------------------------------------------=
----------*/
> +/* Remote Ring Debugging Helpers =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> +/*------------------------------------------------------------------=
----------*/
> +
> +#ifdef DEBUG_DUMP_RINGS
> +static void dump_rem_desc(struct vop_vq *vq)
> +{
> + =A0 =A0 =A0 struct vop_loc_desc desc;
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 dev_dbg(vq->dev, "REM DESC 0xADDRESSX LENGTH 0xFLAG NEX=
T\n");
> + =A0 =A0 =A0 for (i =3D 0; i < VOP_RING_SIZE; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_rem_desc(vq, i, &desc);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "DESC %.2d: 0x%.8x %.6=
d 0x%.4x %.2d\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 i, desc=
=2Eaddr, desc.len, desc.flags, desc.next);
> + =A0 =A0 =A0 }
> +}
> +
> +static void dump_rem_avail(struct vop_vq *vq)
> +{
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 dev_dbg(vq->dev, "REM AVAIL IDX %.2d\n", le16_to_cpu(vq=
->guest->avail_idx));
> + =A0 =A0 =A0 for (i =3D 0; i < VOP_RING_SIZE; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "REM AVAIL %.2d: %.2d\=
n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 i, le16=
_to_cpu(vq->guest->avail[i]));
> + =A0 =A0 =A0 }
> +}
> +
> +static void dump_rem_used(struct vop_vq *vq)
> +{
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 dev_dbg(vq->dev, "REM USED IDX %.2d\n", ioread16(&vq->h=
ost->used_idx));
> + =A0 =A0 =A0 for (i =3D 0; i < VOP_RING_SIZE; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "REM USED %.2d: %.2d %=
=2E6d\n", i,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioread3=
2(&vq->host->used[i].id),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioread3=
2(&vq->host->used[i].len));
> + =A0 =A0 =A0 }
> +}
> +
> +static void dump_rem_rings(struct vop_vq *vq)
> +{
> + =A0 =A0 =A0 dump_rem_desc(vq);
> + =A0 =A0 =A0 dump_rem_avail(vq);
> + =A0 =A0 =A0 dump_rem_used(vq);
> +}
> +
> +/*------------------------------------------------------------------=
----------*/
> +/* Local Ring Debugging Helpers =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> +/*------------------------------------------------------------------=
----------*/
> +
> +static void dump_loc_desc(struct vop_vq *vq)
> +{
> + =A0 =A0 =A0 struct vop_loc_desc desc;
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 dev_dbg(vq->dev, "LOC DESC 0xADDRESSX LENGTH 0xFLAG NEX=
T\n");
> + =A0 =A0 =A0 for (i =3D 0 ; i < VOP_RING_SIZE; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_loc_desc(vq, i, &desc);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "DESC %.2d: 0x%.8x %.6=
d 0x%.4x %.2d\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 i, desc=
=2Eaddr, desc.len, desc.flags, desc.next);
> + =A0 =A0 =A0 }
> +}
> +
> +static void dump_loc_avail(struct vop_vq *vq)
> +{
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 dev_dbg(vq->dev, "LOC AVAIL IDX %.2d\n", vq->avail.inde=
x);
> + =A0 =A0 =A0 for (i =3D 0; i < VOP_RING_SIZE; i++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "LOC AVAIL %.2d: %.2d\=
n", i, vq->avail.ring[i]);
> +}
> +
> +static void dump_loc_used(struct vop_vq *vq)
> +{
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 dev_dbg(vq->dev, "LOC USED IDX %.2hu\n", vq->used.index=
);
> + =A0 =A0 =A0 for (i =3D 0; i < VOP_RING_SIZE; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "LOC USED %.2d: %.2d %=
=2E6d\n", i,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->use=
d.ring[i].id, vq->used.ring[i].len);
> + =A0 =A0 =A0 }
> +}
> +
> +static void dump_loc_rings(struct vop_vq *vq)
> +{
> + =A0 =A0 =A0 dump_loc_desc(vq);
> + =A0 =A0 =A0 dump_loc_avail(vq);
> + =A0 =A0 =A0 dump_loc_used(vq);
> +}
> +
> +static void debug_dump_rings(struct vop_vq *vq, const char *msg)
> +{
> + =A0 =A0 =A0 dev_dbg(vq->dev, "\n");
> + =A0 =A0 =A0 dev_dbg(vq->dev, "%s\n", msg);
> + =A0 =A0 =A0 dump_loc_rings(vq);
> + =A0 =A0 =A0 dump_rem_rings(vq);
> + =A0 =A0 =A0 dev_dbg(vq->dev, "\n");
> +}
> +#else
> +static void debug_dump_rings(struct vop_vq *vq, const char *msg)
> +{
> + =A0 =A0 =A0 /* Nothing */
> +}
> +#endif
> +
> +/*------------------------------------------------------------------=
----------*/
> +/* Scatterlist DMA helpers =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> +/*------------------------------------------------------------------=
----------*/
> +
> +/*
> + * This function abuses some of the scatterlist code and implements
> + * dma_map_sg() in such a way that we don't need to keep the scatter=
list
> + * around in order to unmap it.
> + *
> + * It is also designed to never merge scatterlist entries, which is
> + * never what we want for virtio.
> + *
> + * When it is time to unmap the buffer, you can use dma_unmap_single=
() to
> + * unmap each entry in the chain. Get the address, length, and direc=
tion
> + * from the descriptors! (keep a local copy for speed)
> + */
> +static int vop_dma_map_sg(struct device *dev, struct scatterlist sg[=
],
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int out, u=
nsigned int in)
> +{
> + =A0 =A0 =A0 dma_addr_t addr;
> + =A0 =A0 =A0 enum dma_data_direction dir;
> + =A0 =A0 =A0 struct scatterlist *start;
> + =A0 =A0 =A0 unsigned int i, failure;
> +
> + =A0 =A0 =A0 start =3D sg;
> +
> + =A0 =A0 =A0 for (i =3D 0; i < out + in; i++) {
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Check for scatterlist chaining abuse=
 */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(sg =3D=3D NULL);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dir =3D (i < out) ? DMA_TO_DEVICE : DMA=
_FROM_DEVICE;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 addr =3D dma_map_single(dev, sg_virt(sg=
), sg->length, dir);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (dma_mapping_error(dev, addr))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto unwind;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sg_dma_address(sg) =3D addr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sg =3D sg_next(sg);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return 0;
> +
> +unwind:
> + =A0 =A0 =A0 failure =3D i;
> + =A0 =A0 =A0 sg =3D start;
> +
> + =A0 =A0 =A0 for (i =3D 0; i < failure; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dir =3D (i < out) ? DMA_TO_DEVICE : DMA=
_FROM_DEVICE;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 addr =3D sg_dma_address(sg);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma_unmap_single(dev, addr, sg->length,=
 dir);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sg =3D sg_next(sg);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return -ENOMEM;
> +}
> +
> +/*------------------------------------------------------------------=
----------*/
> +/* DMA Helpers =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
*/
> +/*------------------------------------------------------------------=
----------*/
> +
> +/*
> + * Transfer data between two physical addresses with DMA
> + *
> + * NOTE: does not automatically unmap the src and dst addresses
> + *
> + * @chan the channel to use
> + * @dst the physical destination address
> + * @src the physical source address
> + * @len the length to transfer (in bytes)
> + * @return a valid cookie, or -ERRNO
> + */
> +static dma_cookie_t dma_async_memcpy_raw_to_raw(struct dma_chan *cha=
n,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0dma_addr_t dst,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0dma_addr_t src,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0size_t len)
> +{
> + =A0 =A0 =A0 struct dma_device *dev =3D chan->device;
> + =A0 =A0 =A0 struct dma_async_tx_descriptor *tx;
> + =A0 =A0 =A0 enum dma_ctrl_flags flags;
> + =A0 =A0 =A0 dma_cookie_t cookie;
> + =A0 =A0 =A0 int cpu;
> +
> + =A0 =A0 =A0 flags =3D DMA_COMPL_SKIP_SRC_UNMAP | DMA_COMPL_SKIP_DES=
T_UNMAP;
> + =A0 =A0 =A0 tx =3D dev->device_prep_dma_memcpy(chan, dst, src, len,=
 flags);
> + =A0 =A0 =A0 if (!tx)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> +
> + =A0 =A0 =A0 tx->callback =3D NULL;
> + =A0 =A0 =A0 cookie =3D tx->tx_submit(tx);
> +
> + =A0 =A0 =A0 cpu =3D get_cpu();
> + =A0 =A0 =A0 per_cpu_ptr(chan->local, cpu)->bytes_transferred +=3D l=
en;
> + =A0 =A0 =A0 per_cpu_ptr(chan->local, cpu)->memcpy_count++;
> + =A0 =A0 =A0 put_cpu();
> +
> + =A0 =A0 =A0 return cookie;
> +}
> +
> +/*
> + * Trigger an interrupt after all DMA issued up to this point
> + * have been processed
> + *
> + * @chan the channel to use
> + * @callback the function to call (must not sleep)
> + * @data the data to send to the callback
> + *
> + * @return a valid cookie, or -ERRNO
> + */
> +static dma_cookie_t dma_async_interrupt(struct dma_chan *chan,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 dma_async_tx_callback callback,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 void *data)
> +{
> + =A0 =A0 =A0 struct dma_device *dev =3D chan->device;
> + =A0 =A0 =A0 struct dma_async_tx_descriptor *tx;
> +
> + =A0 =A0 =A0 /* Set up the DMA */
> + =A0 =A0 =A0 tx =3D dev->device_prep_dma_interrupt(chan, DMA_PREP_IN=
TERRUPT);
> + =A0 =A0 =A0 if (!tx)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> +
> + =A0 =A0 =A0 tx->callback =3D callback;
> + =A0 =A0 =A0 tx->callback_param =3D data;
> +
> + =A0 =A0 =A0 return tx->tx_submit(tx);
> +}
> +
> +/*------------------------------------------------------------------=
----------*/
> +/* DMA Resolver =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 */
> +/*------------------------------------------------------------------=
----------*/
> +
> +static void vop_remote_used_changed(struct vop_vq *vq)
> +{
> + =A0 =A0 =A0 if (!(vop_get_host_flags(vq) & VOP_F_NO_INTERRUPT)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "notifying the host (n=
ew buffers in used)\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 iowrite32(vq->kick_val, vq->immr + ODR_=
OFFSET);
> + =A0 =A0 =A0 }
> +}
> +
> +static void vop_local_used_changed(struct vop_vq *vq)
> +{
> + =A0 =A0 =A0 if (!(vq->flags & VOP_F_NO_INTERRUPT)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "notifying self (new b=
uffers in used)\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->vq.callback(&vq->vq);
> + =A0 =A0 =A0 }
> +}
> +
> +/*
> + * DMA callback function for merged rxbufs
> + *
> + * This is called every time a DMA transfer completes, and will upda=
te the
> + * indices in the local and remote used rings, then notify both side=
s that
> + * their used ring has changed
> + *
> + * You must be sure that the data was actually written to the used r=
ings before
> + * this function is called
> + */
> +static void dma_callback(void *data)
> +{
> + =A0 =A0 =A0 struct vop_dma_cbinfo *cb =3D data;
> + =A0 =A0 =A0 struct vop_vq *vq =3D cb->vq;
> +
> + =A0 =A0 =A0 dev_dbg(vq->dev, "%s: vq %p loc %d rem %d\n", __func__,=
 vq, cb->loc, cb->rem);
> +
> + =A0 =A0 =A0 /* Write the local used index */
> + =A0 =A0 =A0 vq->used.index +=3D cb->loc;
> +
> + =A0 =A0 =A0 /* Write the remote used index */
> + =A0 =A0 =A0 vq->rem_last_used +=3D cb->rem;
> + =A0 =A0 =A0 iowrite16(vq->rem_last_used, &vq->host->used_idx);
> +
> + =A0 =A0 =A0 /* Make sure the indices are written before triggering =
callbacks */
> + =A0 =A0 =A0 wmb();
> +
> + =A0 =A0 =A0 /* Trigger the local used callback */
> + =A0 =A0 =A0 dev_dbg(vq->dev, "local used changed, running callback\=
n");
> + =A0 =A0 =A0 vop_local_used_changed(vq);
> +
> + =A0 =A0 =A0 /* Trigger the remote used callback */
> + =A0 =A0 =A0 dev_dbg(vq->dev, "remote used changed, running callback=
\n");
> + =A0 =A0 =A0 vop_remote_used_changed(vq);
> +
> + =A0 =A0 =A0 /* Free the callback data */
> + =A0 =A0 =A0 kmem_cache_free(dma_cache, cb);
> +}
> +
> +/*
> + * Take an entry from the local avail ring and add it to the local
> + * used ring with the given length
> + *
> + * NOTE: does not update the used index
> + *
> + * @vq the virtqueue
> + * @avail_idx the index in the avail ring to take the entry from
> + * @used_idx the index in the used ring to put the entry
> + * @used_len the length used
> + */
> +static void vop_loc_avail_to_used(struct vop_vq *vq, unsigned int av=
ail_idx,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 uns=
igned int used_idx, u32 used_len)
> +{
> + =A0 =A0 =A0 u16 id;
> +
> + =A0 =A0 =A0 /* Make sure the indices are inside the rings */
> + =A0 =A0 =A0 avail_idx &=3D (VOP_RING_SIZE - 1);
> + =A0 =A0 =A0 used_idx =A0&=3D (VOP_RING_SIZE - 1);
> +
> + =A0 =A0 =A0 /* Get the index stored in the avail ring */
> + =A0 =A0 =A0 id =3D vq->avail.ring[avail_idx];
> +
> + =A0 =A0 =A0 /* Copy the index and length to the used ring */
> + =A0 =A0 =A0 vq->used.ring[used_idx].id =3D id;
> + =A0 =A0 =A0 vq->used.ring[used_idx].len =3D used_len;
> +}
> +
> +/*
> + * Take an entry from the remote avail ring and add it to the remote
> + * used ring with the given length
> + *
> + * NOTE: does not update the used index
> + *
> + * @vq the virtqueue
> + * @avail_idx the index in the avail ring to take the entry from
> + * @used_idx the index in the used ring to put the entry
> + * @used_len the length used
> + */
> +static void vop_rem_avail_to_used(struct vop_vq *vq, unsigned int av=
ail_idx,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 uns=
igned int used_idx, u32 used_len)
> +{
> + =A0 =A0 =A0 u16 id;
> +
> + =A0 =A0 =A0 /* Make sure the indices are inside the rings */
> + =A0 =A0 =A0 avail_idx &=3D (VOP_RING_SIZE - 1);
> + =A0 =A0 =A0 used_idx =A0&=3D (VOP_RING_SIZE - 1);
> +
> + =A0 =A0 =A0 /* Get the index stored in the avail ring */
> + =A0 =A0 =A0 id =3D le16_to_cpu(vq->guest->avail[avail_idx]);
> +
> + =A0 =A0 =A0 /* Copy the index and length to the used ring */
> + =A0 =A0 =A0 iowrite32(id, &vq->host->used[used_idx].id);
> + =A0 =A0 =A0 iowrite32(used_len, &vq->host->used[used_idx].len);
> +}
> +
> +/*
> + * Return the number of entries available in the local avail ring
> + */
> +static unsigned int loc_num_avail(struct vop_vq *vq)
> +{
> + =A0 =A0 =A0 return vq->avail.index - vq->dma.loc_avail;
> +}
> +
> +/*
> + * Return the number of entries available in the remote avail ring
> + */
> +static unsigned int rem_num_avail(struct vop_vq *vq)
> +{
> + =A0 =A0 =A0 return le16_to_cpu(vq->guest->avail_idx) - vq->dma.rem_=
avail;
> +}
> +
> +/*
> + * Return a descriptor id from the local avail ring
> + *
> + * @vq the virtqueue
> + * @idx the index to return the id from
> + */
> +static u16 vop_loc_avail_id(struct vop_vq *vq, unsigned int idx)
> +{
> + =A0 =A0 =A0 idx &=3D (VOP_RING_SIZE - 1);
> + =A0 =A0 =A0 return vq->avail.ring[idx];
> +}
> +
> +/*
> + * Return a descriptor id from the remote avail ring
> + *
> + * @vq the virtqueue
> + * @idx the index to return the id from
> + */
> +static u16 vop_rem_avail_id(struct vop_vq *vq, unsigned int idx)
> +{
> + =A0 =A0 =A0 idx &=3D (VOP_RING_SIZE - 1);
> + =A0 =A0 =A0 return le16_to_cpu(vq->guest->avail[idx]);
> +}
> +
> +/*------------------------------------------------------------------=
----------*/
> +/* Extra helpers for mergeable DMA =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> +/*------------------------------------------------------------------=
----------*/
> +
> +/*
> + * TODO: the number of bytes being transmitted could be added to the=
 avail
> + * TODO: ring, rather than just an index. I'm not sure it would make=
 much
> + * TODO: difference, though.
> + */
> +
> +/*
> + * Calculate the number of bytes used in a local descriptor chain
> + *
> + * @vq the virtqueue
> + * @idx the start descriptor index
> + * @return the number of bytes
> + */
> +static unsigned int loc_num_bytes(struct vop_vq *vq, unsigned int id=
x)
> +{
> + =A0 =A0 =A0 struct vop_loc_desc desc;
> + =A0 =A0 =A0 unsigned int bytes =3D 0;
> +
> + =A0 =A0 =A0 while (true) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_loc_desc(vq, idx, &desc);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bytes +=3D desc.len;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(desc.flags & VOP_DESC_F_NEXT))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 idx =3D desc.next;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return bytes;
> +}
> +
> +/*
> + * Calculate the number of bytes used in a remote descriptor chain
> + *
> + * @vq the virtqueue
> + * @idx the start descriptor index
> + * @return the number of bytes
> + */
> +static unsigned int rem_num_bytes(struct vop_vq *vq, unsigned int id=
x)
> +{
> + =A0 =A0 =A0 struct vop_loc_desc desc;
> + =A0 =A0 =A0 unsigned int bytes =3D 0;
> +
> + =A0 =A0 =A0 while (true) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_rem_desc(vq, idx, &desc);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bytes +=3D desc.len;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(desc.flags & VOP_DESC_F_NEXT))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 idx =3D desc.next;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return bytes;
> +}
> +
> +/*
> + * Transmit the next local available entry to the remote side, split=
ting
> + * up the local descriptor as needed
> + *
> + * This routine makes the following assumptions:
> + * 1) The header already has the correct number of buffers set
> + * 2) The available buffers are all PAGE_SIZE
> + */
> +static int vop_dma_xmit(struct vop_vq *vq)
> +{
> + =A0 =A0 =A0 struct vop_dma_info *dma =3D &vq->dma;
> + =A0 =A0 =A0 struct dma_chan *chan =3D dma->chan;
> + =A0 =A0 =A0 dma_cookie_t cookie;
> +
> + =A0 =A0 =A0 unsigned int loc_idx, rem_idx;
> + =A0 =A0 =A0 struct vop_loc_desc loc, rem;
> +
> + =A0 =A0 =A0 struct vop_dma_cbinfo *cb;
> + =A0 =A0 =A0 dma_addr_t src, dst;
> + =A0 =A0 =A0 size_t len;
> +
> + =A0 =A0 =A0 unsigned int loc_total =3D 0;
> + =A0 =A0 =A0 unsigned int rem_total =3D 0;
> + =A0 =A0 =A0 unsigned int bufs_used =3D 0;
> +
> + =A0 =A0 =A0 /* Check that there is a local descriptor available */
> + =A0 =A0 =A0 if (!loc_num_avail(vq)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "No local descriptors =
available\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOSPC;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Get the starting entry from each available ring */
> + =A0 =A0 =A0 loc_idx =3D vop_loc_avail_id(vq, dma->loc_avail);
> + =A0 =A0 =A0 rem_idx =3D vop_rem_avail_id(vq, dma->rem_avail);
> +
> + =A0 =A0 =A0 dev_dbg(vq->dev, "rem_avail %d loc_num_bytes %d\n", rem=
_num_avail(vq), loc_num_bytes(vq, loc_idx));
> +
> + =A0 =A0 =A0 /* Check that there are enough remote buffers available=
 */
> + =A0 =A0 =A0 if (rem_num_avail(vq) * PAGE_SIZE < loc_num_bytes(vq, l=
oc_idx)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "Insufficient remote d=
escriptors available\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOSPC;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Allocate DMA callback data */
> + =A0 =A0 =A0 cb =3D kmem_cache_alloc(dma_cache, GFP_KERNEL);
> + =A0 =A0 =A0 if (!cb) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "Unable to allocate DM=
A callback data\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Load the starting descriptors */
> + =A0 =A0 =A0 vop_loc_desc(vq, loc_idx, &loc);
> + =A0 =A0 =A0 vop_rem_desc(vq, rem_idx, &rem);
> +
> + =A0 =A0 =A0 while (true) {
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dst =3D rem.addr + 0x80000000;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 src =3D loc.addr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 len =3D min(loc.len, rem.len);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "DMA xmit dst %.8x src=
 %.8x len %d\n", dst, src, len);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cookie =3D dma_async_memcpy_raw_to_raw(=
chan, dst, src, len);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (dma_submit_error(cookie)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(vq->dev, "DMA s=
ubmit error\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_free_cb;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 loc.len -=3D len;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rem.len -=3D len;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 loc.addr +=3D len;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rem.addr +=3D len;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 loc_total +=3D len;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rem_total +=3D len;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "loc.len %d rem.len %d=
\n", loc.len, rem.len);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "loc.addr %.8x rem.add=
r %.8x\n", loc.addr, rem.addr);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "loc_total %d rem_tota=
l %d\n", loc_total, rem_total);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (loc.len =3D=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "local=
: descriptor depleted, loading next\n");
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(loc.flags & VOP_D=
ESC_F_NEXT)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg=
(vq->dev, "local: no next descriptor, chain finished\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "local=
: fetching next descriptor\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 loc_idx =3D loc.next;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_loc_desc(vq, loc_id=
x, &loc);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (rem.len =3D=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "remot=
e: descriptor depleted, adding to used\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_rem_avail_to_used(v=
q, dma->rem_avail + bufs_used, dma->rem_used + bufs_used, rem_total);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bufs_used++;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "remot=
e: fetching next descriptor\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rem_idx =3D vop_rem_ava=
il_id(vq, dma->rem_avail + bufs_used);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_rem_desc(vq, rem_id=
x, &rem);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rem_total =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Add the last remote descriptor to the used ring */
> + =A0 =A0 =A0 BUG_ON(rem_total =3D=3D 0);
> + =A0 =A0 =A0 dev_dbg(vq->dev, "adding last remote descriptor to used=
 ring\n");
> + =A0 =A0 =A0 vop_rem_avail_to_used(vq, dma->rem_avail + bufs_used, d=
ma->rem_used + bufs_used, rem_total);
> + =A0 =A0 =A0 bufs_used++;
> +
> + =A0 =A0 =A0 /* Add the local descriptor to the sude ring */
> + =A0 =A0 =A0 dev_dbg(vq->dev, "adding only local descriptor to used =
ring\n");
> + =A0 =A0 =A0 vop_loc_avail_to_used(vq, dma->loc_avail, dma->loc_used=
, loc_total);
> +
> + =A0 =A0 =A0 /* Make very sure that everything written to the rings =
actually happened
> + =A0 =A0 =A0 =A0* bofer the DMA callback can be triggered */
> + =A0 =A0 =A0 wmb();
> +
> + =A0 =A0 =A0 /* Set up the DMA callback information */
> + =A0 =A0 =A0 cb->vq =3D vq;
> + =A0 =A0 =A0 cb->loc =3D 1;
> + =A0 =A0 =A0 cb->rem =3D bufs_used;
> +
> + =A0 =A0 =A0 dev_dbg(vq->dev, "setup DMA callback vq %p loc %d rem %=
d\n", vq, 1, bufs_used);
> +
> + =A0 =A0 =A0 /* Trigger an interrupt when the DMA completes to updat=
e the used
> + =A0 =A0 =A0 =A0* indices and trigger the necessary callbacks */
> + =A0 =A0 =A0 cookie =3D dma_async_interrupt(chan, dma_callback, cb);
> + =A0 =A0 =A0 if (dma_submit_error(cookie)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(vq->dev, "DMA interrupt submit =
error\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_free_cb;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Everything was successful, so update the DMA resolve=
r's state */
> + =A0 =A0 =A0 dma->loc_avail++;
> + =A0 =A0 =A0 dma->rem_avail +=3D bufs_used;
> + =A0 =A0 =A0 dma->loc_used++;
> + =A0 =A0 =A0 dma->rem_used +=3D bufs_used;
> +
> + =A0 =A0 =A0 /* Start the DMA */
> + =A0 =A0 =A0 dev_dbg(vq->dev, "DMA xmit setup successful, starting\n=
");
> + =A0 =A0 =A0 dma_async_memcpy_issue_pending(chan);
> +
> + =A0 =A0 =A0 return 0;
> +
> +out_free_cb:
> + =A0 =A0 =A0 kmem_cache_free(dma_cache, cb);
> + =A0 =A0 =A0 return -ENOMEM;
> +}
> +
> +/*
> + * Receive the next remote available entry to the local side, splitt=
ing
> + * up the remote descriptor as needed
> + *
> + * This routine makes the following assumptions:
> + * 1) The header already has the correct number of buffers set
> + * 2) The available buffers are all PAGE_SIZE
> + */
> +static int vop_dma_recv(struct vop_vq *vq)
> +{
> + =A0 =A0 =A0 struct vop_dma_info *dma =3D &vq->dma;
> + =A0 =A0 =A0 struct dma_chan *chan =3D dma->chan;
> + =A0 =A0 =A0 dma_cookie_t cookie;
> +
> + =A0 =A0 =A0 unsigned int loc_idx, rem_idx;
> + =A0 =A0 =A0 struct vop_loc_desc loc, rem;
> +
> + =A0 =A0 =A0 struct vop_dma_cbinfo *cb;
> + =A0 =A0 =A0 dma_addr_t src, dst;
> + =A0 =A0 =A0 size_t len;
> +
> + =A0 =A0 =A0 unsigned int loc_total =3D 0;
> + =A0 =A0 =A0 unsigned int rem_total =3D 0;
> + =A0 =A0 =A0 unsigned int bufs_used =3D 0;
> +
> + =A0 =A0 =A0 /* Check that there is a remote descriptor available */
> + =A0 =A0 =A0 if (!rem_num_avail(vq)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "No remote descriptors=
 available\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOSPC;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Get the starting entry from each available ring */
> + =A0 =A0 =A0 loc_idx =3D vop_loc_avail_id(vq, dma->loc_avail);
> + =A0 =A0 =A0 rem_idx =3D vop_rem_avail_id(vq, dma->rem_avail);
> +
> + =A0 =A0 =A0 /* Check that there are enough local buffers available =
*/
> + =A0 =A0 =A0 if (loc_num_avail(vq) * PAGE_SIZE < rem_num_bytes(vq, r=
em_idx)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "Insufficient local de=
scriptors available\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOSPC;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Allocate DMA callback data */
> + =A0 =A0 =A0 cb =3D kmem_cache_alloc(dma_cache, GFP_KERNEL);
> + =A0 =A0 =A0 if (!cb) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "Unable to allocate DM=
A callback data\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Load the starting descriptors */
> + =A0 =A0 =A0 vop_loc_desc(vq, loc_idx, &loc);
> + =A0 =A0 =A0 vop_rem_desc(vq, rem_idx, &rem);
> +
> + =A0 =A0 =A0 while (true) {
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dst =3D loc.addr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 src =3D rem.addr + 0x80000000;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 len =3D min(loc.len, rem.len);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "DMA recv dst %.8x src=
 %.8x len %d\n", dst, src, len);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cookie =3D dma_async_memcpy_raw_to_raw(=
chan, dst, src, len);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (dma_submit_error(cookie)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(vq->dev, "DMA s=
ubmit error\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_free_cb;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 loc.len -=3D len;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rem.len -=3D len;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 loc.addr +=3D len;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rem.addr +=3D len;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 loc_total +=3D len;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rem_total +=3D len;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (rem.len =3D=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(rem.flags & VOP_D=
ESC_F_NEXT))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rem_idx =3D rem.next;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_rem_desc(vq, rem_id=
x, &rem);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (loc.len =3D=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_loc_avail_to_used(v=
q, dma->loc_avail + bufs_used, dma->loc_used + bufs_used, loc_total);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bufs_used++;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 loc_idx =3D vop_loc_ava=
il_id(vq, dma->loc_avail + bufs_used);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_loc_desc(vq, loc_id=
x, &loc);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 loc_total =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Add the last local descriptor to the used ring */
> + =A0 =A0 =A0 BUG_ON(loc_total =3D=3D 0);
> + =A0 =A0 =A0 vop_loc_avail_to_used(vq, dma->loc_avail + bufs_used, d=
ma->loc_used + bufs_used, loc_total);
> + =A0 =A0 =A0 bufs_used++;
> +
> + =A0 =A0 =A0 /* Add the remote descriptor to the used ring */
> + =A0 =A0 =A0 vop_rem_avail_to_used(vq, dma->rem_avail, dma->rem_used=
, rem_total);
> +
> + =A0 =A0 =A0 /* Make very sure that everything written to the rings =
actually happened
> + =A0 =A0 =A0 =A0* before the DMA callback can be triggered */
> + =A0 =A0 =A0 wmb();
> +
> + =A0 =A0 =A0 /* Set up the DMA callback information */
> + =A0 =A0 =A0 cb->vq =3D vq;
> + =A0 =A0 =A0 cb->loc =3D bufs_used;
> + =A0 =A0 =A0 cb->rem =3D 1;
> +
> + =A0 =A0 =A0 /* Trigger an interrupt when the DMA completes to updat=
e the used
> + =A0 =A0 =A0 =A0* indices and trigger the necessary callbacks */
> + =A0 =A0 =A0 cookie =3D dma_async_interrupt(chan, dma_callback, cb);
> + =A0 =A0 =A0 if (dma_submit_error(cookie)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(vq->dev, "DMA interrupt submit =
error\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_free_cb;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Everything was successful, so update the DMA resolve=
r's state */
> + =A0 =A0 =A0 dma->loc_avail +=3D bufs_used;
> + =A0 =A0 =A0 dma->rem_avail++;
> + =A0 =A0 =A0 dma->loc_used +=3D bufs_used;
> + =A0 =A0 =A0 dma->rem_used++;
> +
> + =A0 =A0 =A0 /* Start the DMA */
> + =A0 =A0 =A0 dev_dbg(vq->dev, "DMA recv setup successful, starting\n=
");
> + =A0 =A0 =A0 dma_async_memcpy_issue_pending(chan);
> +
> + =A0 =A0 =A0 return 0;
> +
> +out_free_cb:
> + =A0 =A0 =A0 kmem_cache_free(dma_cache, cb);
> + =A0 =A0 =A0 return -ENOMEM;
> +}
> +
> +/*------------------------------------------------------------------=
----------*/
> +/* Virtqueue Ops Infrastructure =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> +/*------------------------------------------------------------------=
----------*/
> +
> +/*
> + * Modify the struct virtio_net_hdr_mrg_rxbuf's num_buffers field to=
 account
> + * for the split that will happen in the DMA xmit routine
> + *
> + * This assumes that both sides have the same PAGE_SIZE
> + */
> +static void vop_fixup_vnet_mrg_hdr(struct scatterlist sg[], unsigned=
 int out)
> +{
> + =A0 =A0 =A0 struct virtio_net_hdr *hdr;
> + =A0 =A0 =A0 struct virtio_net_hdr_mrg_rxbuf *mhdr;
> + =A0 =A0 =A0 unsigned int bytes =3D 0;
> +
> + =A0 =A0 =A0 /* There must be a header + data, at the least */
> + =A0 =A0 =A0 BUG_ON(out < 2);
> +
> + =A0 =A0 =A0 /* The first entry must be the structure */
> + =A0 =A0 =A0 BUG_ON(sg->length !=3D sizeof(struct virtio_net_hdr_mrg=
_rxbuf));
> +
> + =A0 =A0 =A0 hdr =3D sg_virt(sg);
> + =A0 =A0 =A0 mhdr =3D sg_virt(sg);
> +
> + =A0 =A0 =A0 /* We merge buffers together, so just count up the numb=
er of bytes
> + =A0 =A0 =A0 =A0* needed, then figure out how many pages that will b=
e */
> + =A0 =A0 =A0 for (/* none */; out; out--, sg =3D sg_next(sg))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bytes +=3D sg->length;
> +
> + =A0 =A0 =A0 /* Of course, nobody ever imagined that we might actual=
ly use
> + =A0 =A0 =A0 =A0* this on machines with different endianness...
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* We force little-endian for now, since that's what =
our host is */
> + =A0 =A0 =A0 mhdr->num_buffers =3D cpu_to_le16(DIV_ROUND_UP(bytes, P=
AGE_SIZE));
> +
> + =A0 =A0 =A0 /* Might as well fix up the other fields while we're at=
 it */
> + =A0 =A0 =A0 hdr->hdr_len =3D cpu_to_le16(hdr->hdr_len);
> + =A0 =A0 =A0 hdr->gso_size =3D cpu_to_le16(hdr->gso_size);
> + =A0 =A0 =A0 hdr->csum_start =3D cpu_to_le16(hdr->csum_start);
> + =A0 =A0 =A0 hdr->csum_offset =3D cpu_to_le16(hdr->csum_offset);
> +}
> +
> +/*
> + * Add a buffer to our local descriptors and the local avail ring
> + *
> + * NOTE: there hasn't been any transfer yet, just adding to local
> + * NOTE: rings. The kick() will process any DMA that needs to happen
> + *
> + * @return 0 on success, -ERRNO otherwise
> + */
> +static int vop_add_buf(struct virtqueue *_vq, struct scatterlist sg[=
],
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned int out, unsign=
ed int in, void *data)
> +{
> + =A0 =A0 =A0 /* For now, we'll just add the buffers to our local des=
criptors and
> + =A0 =A0 =A0 =A0* avail ring */
> + =A0 =A0 =A0 struct vop_vq *vq =3D to_vop_vq(_vq);
> + =A0 =A0 =A0 unsigned int i, avail, head, uninitialized_var(prev);
> +
> + =A0 =A0 =A0 BUG_ON(data =3D=3D NULL);
> + =A0 =A0 =A0 BUG_ON(out + in =3D=3D 0);
> +
> + =A0 =A0 =A0 /* Make sure we have space for this to succeed */
> + =A0 =A0 =A0 if (vq->num_free < out + in) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "No free space left: l=
en=3D%d free=3D%d\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 out + i=
n, vq->num_free);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOSPC;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* If this is an xmit buffer from virtio_net, fixup the=
 header */
> + =A0 =A0 =A0 if (out > 1) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "Fixing up virtio_net =
header\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_fixup_vnet_mrg_hdr(sg, out);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 head =3D vq->free_head;
> +
> + =A0 =A0 =A0 /* DMA map the scatterlist */
> + =A0 =A0 =A0 if (vop_dma_map_sg(vq->dev, sg, out, in)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(vq->dev, "Failed to DMA map sca=
tterlist\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* We're about to use some buffers from the free list *=
/
> + =A0 =A0 =A0 vq->num_free -=3D out + in;
> +
> + =A0 =A0 =A0 for (i =3D vq->free_head; out; i =3D vop_get_desc_next(=
vq, i), out--) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_set_desc_flags(vq, i, VOP_DESC_F_NE=
XT);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_set_desc_addr(vq, i, sg_dma_address=
(sg));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_set_desc_len(vq, i, sg->length);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 prev =3D i;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sg =3D sg_next(sg);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 for (/* none */; in; i =3D vop_get_desc_next(vq, i), in=
--) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_set_desc_flags(vq, i, VOP_DESC_F_NE=
XT | VOP_DESC_F_WRITE);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_set_desc_addr(vq, i, sg_dma_address=
(sg));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_set_desc_len(vq, i, sg->length);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 prev =3D i;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sg =3D sg_next(sg);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Last one doesn't continue */
> + =A0 =A0 =A0 vop_set_desc_flags(vq, prev, vop_get_desc_flags(vq, pre=
v) & ~VOP_DESC_F_NEXT);
> +
> + =A0 =A0 =A0 /* Update the free pointer */
> + =A0 =A0 =A0 vq->free_head =3D i;
> +
> + =A0 =A0 =A0 /* Set token */
> + =A0 =A0 =A0 vq->data[head] =3D data;
> +
> + =A0 =A0 =A0 /* Add an entry for the head of the chain into the avai=
l array, but
> + =A0 =A0 =A0 =A0* don't update avail->idx until kick() */
> + =A0 =A0 =A0 avail =3D (vq->avail.index + vq->num_added++) & (VOP_RI=
NG_SIZE - 1);
> + =A0 =A0 =A0 vq->avail.ring[avail] =3D head;
> +
> + =A0 =A0 =A0 dev_dbg(vq->dev, "Added buffer head %i to %p\n", head, =
vq);
> + =A0 =A0 =A0 debug_dump_rings(vq, "Added buffer(s), dumping rings");
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static inline bool loc_more_used(const struct vop_vq *vq)
> +{
> + =A0 =A0 =A0 return vq->loc_last_used !=3D vq->used.index;
> +}
> +
> +static void detach_buf(struct vop_vq *vq, unsigned int head)
> +{
> + =A0 =A0 =A0 dma_addr_t addr;
> + =A0 =A0 =A0 unsigned int idx, len;
> + =A0 =A0 =A0 enum dma_data_direction dir;
> + =A0 =A0 =A0 struct vop_loc_desc desc;
> +
> + =A0 =A0 =A0 /* Clear data pointer */
> + =A0 =A0 =A0 vq->data[head] =3D NULL;
> +
> + =A0 =A0 =A0 /* Put the chain back on the free list, unmapping as we=
 go */
> + =A0 =A0 =A0 idx =3D head;
> + =A0 =A0 =A0 while (true) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_loc_desc(vq, idx, &desc);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 addr =3D desc.addr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 len =A0=3D desc.len;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dir =A0=3D (desc.flags & VOP_DESC_F_WRI=
TE) ? DMA_FROM_DEVICE : DMA_TO_DEVICE;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Unmap the entry */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma_unmap_single(vq->dev, addr, len, di=
r);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->num_free++;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* If there is no next descriptor, we'r=
e done */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(desc.flags & VOP_DESC_F_NEXT))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 idx =3D desc.next;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 vop_set_desc_next(vq, idx, vq->free_head);
> + =A0 =A0 =A0 vq->free_head =3D head;
> +}
> +
> +/*
> + * Get a buffer from the used ring
> + *
> + * @return the data token given to add_buf(), or NULL if there
> + * =A0 =A0 =A0 =A0 are no remaining buffers
> + */
> +static void *vop_get_buf(struct virtqueue *_vq, unsigned int *len)
> +{
> + =A0 =A0 =A0 struct vop_vq *vq =3D to_vop_vq(_vq);
> + =A0 =A0 =A0 unsigned int head, used;
> + =A0 =A0 =A0 void *ret;
> +
> + =A0 =A0 =A0 if (!loc_more_used(vq)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "No more buffers in qu=
eue\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 used =3D vq->loc_last_used & (VOP_RING_SIZE - 1);
> + =A0 =A0 =A0 head =3D vq->used.ring[used].id;
> + =A0 =A0 =A0 *len =3D vq->used.ring[used].len;
> +
> + =A0 =A0 =A0 BUG_ON(head >=3D VOP_RING_SIZE);
> + =A0 =A0 =A0 BUG_ON(!vq->data[head]);
> +
> + =A0 =A0 =A0 /* detach_buf() clears data, save it now */
> + =A0 =A0 =A0 ret =3D vq->data[head];
> + =A0 =A0 =A0 detach_buf(vq, head);
> +
> + =A0 =A0 =A0 /* Update the last local used_idx */
> + =A0 =A0 =A0 vq->loc_last_used++;
> +
> + =A0 =A0 =A0 return ret;
> +}
> +
> +/*
> + * The avail ring changed, so we need to start as much DMA as we can
> + */
> +static void vop_kick(struct virtqueue *_vq)
> +{
> + =A0 =A0 =A0 struct vop_vq *vq =3D to_vop_vq(_vq);
> +
> + =A0 =A0 =A0 dev_dbg(vq->dev, "kick: making %d new buffers available=
\n", vq->num_added);
> + =A0 =A0 =A0 vq->avail.index +=3D vq->num_added;
> + =A0 =A0 =A0 vq->num_added =3D 0;
> +
> + =A0 =A0 =A0 /* Run the DMA resolver */
> + =A0 =A0 =A0 dev_dbg(vq->dev, "kick: using resolver %pS\n", vq->reso=
lve);
> + =A0 =A0 =A0 schedule_work(&vq->work);
> +}
> +
> +/*
> + * Try to disable callbacks on the used ring (unreliable)
> + */
> +static void vop_disable_cb(struct virtqueue *_vq)
> +{
> + =A0 =A0 =A0 struct vop_vq *vq =3D to_vop_vq(_vq);
> + =A0 =A0 =A0 struct virtio_device *vdev =3D _vq->vdev;
> +
> + =A0 =A0 =A0 dev_dbg(&vdev->dev, "disable callbacks\n");
> + =A0 =A0 =A0 vq->flags =3D VOP_F_NO_INTERRUPT;
> +#if 0
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* FIXME: using this causes the host -> guest transfe=
r rate to
> + =A0 =A0 =A0 =A0* FIXME: intermittently slow to 1/10th of the normal=
 rate
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 vop_set_guest_flags(vq, vq->flags);
> +#endif
> +}
> +
> +/*
> + * Enable callbacks on changes to the used ring
> + *
> + * @return false if there are more pending buffers
> + * =A0 =A0 =A0 =A0 true otherwise
> + */
> +static bool vop_enable_cb(struct virtqueue *_vq)
> +{
> + =A0 =A0 =A0 struct vop_vq *vq =3D to_vop_vq(_vq);
> +
> + =A0 =A0 =A0 /* We optimistically enable interrupts, then check if t=
here
> + =A0 =A0 =A0 =A0* was more work to do */
> + =A0 =A0 =A0 dev_dbg(vq->dev, "enable callbacks\n");
> + =A0 =A0 =A0 vq->flags =3D 0;
> +#if 0
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* FIXME: using this causes the host -> guest transfe=
r rate to
> + =A0 =A0 =A0 =A0* FIXME: intermittently slow to 1/10th of the normal=
 rate
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 vop_set_guest_flags(vq, vq->flags);
> +#endif
> +
> + =A0 =A0 =A0 if (unlikely(loc_more_used(vq)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> +
> + =A0 =A0 =A0 return true;
> +}
> +
> +static struct virtqueue_ops vop_vq_ops =3D {
> + =A0 =A0 =A0 .add_buf =A0 =A0 =A0 =A0=3D vop_add_buf,
> + =A0 =A0 =A0 .get_buf =A0 =A0 =A0 =A0=3D vop_get_buf,
> + =A0 =A0 =A0 .kick =A0 =A0 =A0 =A0 =A0 =3D vop_kick,
> + =A0 =A0 =A0 .disable_cb =A0 =A0 =3D vop_disable_cb,
> + =A0 =A0 =A0 .enable_cb =A0 =A0 =A0=3D vop_enable_cb,
> +};
> +
> +/*------------------------------------------------------------------=
----------*/
> +/* Virtio Device Infrastructure =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> +/*------------------------------------------------------------------=
----------*/
> +
> +/* Read some bytes from the host's configuration area */
> +static void vopc_get(struct virtio_device *_vdev, unsigned offset, v=
oid *buf,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned len)
> +{
> + =A0 =A0 =A0 struct vop_vdev *vdev =3D to_vop_vdev(_vdev);
> + =A0 =A0 =A0 void __iomem *config =3D vdev->host_status->config;
> +
> + =A0 =A0 =A0 memcpy_fromio(buf, config + offset, len);
> +}
> +
> +/* Write some bytes to the host's configuration area */
> +static void vopc_set(struct virtio_device *_vdev, unsigned offset,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const void *buf, unsigned le=
n)
> +{
> + =A0 =A0 =A0 struct vop_vdev *vdev =3D to_vop_vdev(_vdev);
> + =A0 =A0 =A0 void __iomem *config =3D vdev->host_status->config;
> +
> + =A0 =A0 =A0 memcpy_toio(config + offset, buf, len);
> +}
> +
> +/* Read your own status bits */
> +static u8 vopc_get_status(struct virtio_device *_vdev)
> +{
> + =A0 =A0 =A0 struct vop_vdev *vdev =3D to_vop_vdev(_vdev);
> + =A0 =A0 =A0 u32 status;
> +
> + =A0 =A0 =A0 status =3D le32_to_cpu(vdev->guest_status->status);
> + =A0 =A0 =A0 dev_dbg(&vdev->vdev.dev, "%s(): -> 0x%.2x\n", __func__,=
 (u8)status);
> +
> + =A0 =A0 =A0 return (u8)status;
> +}
> +
> +static void vopc_set_status(struct virtio_device *_vdev, u8 status)
> +{
> + =A0 =A0 =A0 struct vop_vdev *vdev =3D to_vop_vdev(_vdev);
> + =A0 =A0 =A0 u32 old_status;
> +
> + =A0 =A0 =A0 old_status =3D le32_to_cpu(vdev->guest_status->status);
> + =A0 =A0 =A0 vdev->guest_status->status =3D cpu_to_le32(status);
> +
> + =A0 =A0 =A0 dev_dbg(&vdev->vdev.dev, "%s(): <- 0x%.2x (was 0x%.2x)\=
n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __func__, status, old_s=
tatus);
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* FIXME: we really need to notify the other side whe=
n status changes
> + =A0 =A0 =A0 =A0* FIXME: happen, so that they can take some action
> + =A0 =A0 =A0 =A0*/
> +}
> +
> +static void vopc_reset(struct virtio_device *_vdev)
> +{
> + =A0 =A0 =A0 struct vop_vdev *vdev =3D to_vop_vdev(_vdev);
> +
> + =A0 =A0 =A0 dev_dbg(&vdev->vdev.dev, "%s(): status reset\n", __func=
__);
> + =A0 =A0 =A0 vdev->guest_status->status =3D cpu_to_le32(0);
> +}
> +
> +/* Find the given virtqueue */
> +static struct virtqueue *vopc_find_vq(struct virtio_device *_vdev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0unsigned index,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0void (*cb)(struct virtqueue *vq))
> +{
> + =A0 =A0 =A0 struct vop_vdev *vdev =3D to_vop_vdev(_vdev);
> + =A0 =A0 =A0 struct vop_vq *vq =3D &vdev->virtqueues[index];
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 /* Check that we support the virtqueue at this index */
> + =A0 =A0 =A0 if (index >=3D ARRAY_SIZE(vdev->virtqueues)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&vdev->vdev.dev, "no virtqueue =
for index %d\n", index);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-ENODEV);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* HACK: we only support virtio_net for now */
> + =A0 =A0 =A0 if (vdev->vdev.id.device !=3D VIRTIO_ID_NET) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&vdev->vdev.dev, "only virtio_n=
et is supported\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-ENODEV);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Initialize the virtqueue to a clean state */
> + =A0 =A0 =A0 vq->num_free =3D VOP_RING_SIZE;
> + =A0 =A0 =A0 vq->dev =3D &vdev->vdev.dev;
> + =A0 =A0 =A0 vq->vq.vq_ops =3D &vop_vq_ops;
> +
> + =A0 =A0 =A0 /* Hook up the local virtqueues to the corresponding re=
mote virtqueues */
> + =A0 =A0 =A0 /* TODO: maybe move this to the setup_virtio_net() func=
tion */
> + =A0 =A0 =A0 switch (index) {
> + =A0 =A0 =A0 case 0: /* x86 xmit virtqueue, hook to ppc recv virtque=
ue */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->guest =3D vdev->loc + 2048;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->host =A0=3D vdev->rem + 2048;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->resolve =3D vop_dma_recv;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->kick_val =3D 0x8;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 case 1: /* x86 recv virtqueue, hook to ppc xmit virtque=
ue */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->guest =3D vdev->loc + 1024;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->host =A0=3D vdev->rem + 1024;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->resolve =3D vop_dma_xmit;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->kick_val =3D 0x4;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 case 2: /* x86 ctrl virtqueue -- ppc ctrl virtqueue */
> + =A0 =A0 =A0 default:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(vq->dev, "Unsupported virtqueue=
\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-ENODEV);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 dev_dbg(vq->dev, "vq %d guest %p host %p\n", index, vq-=
>guest, vq->host);
> +
> + =A0 =A0 =A0 /* Initialize the descriptor, avail, and used rings */
> + =A0 =A0 =A0 for (i =3D 0; i < VOP_RING_SIZE; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_set_desc_addr(vq, i, 0x0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_set_desc_len(vq, i, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_set_desc_flags(vq, i, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_set_desc_next(vq, i, (i + 1) & (VOP=
_RING_SIZE - 1));
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->avail.ring[i] =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->used.ring[i].id =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->used.ring[i].len =3D 0;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 vq->avail.index =3D 0;
> + =A0 =A0 =A0 vop_set_guest_flags(vq, 0);
> +
> + =A0 =A0 =A0 /* This is the guest, the host has already initialized =
the rings for us */
> + =A0 =A0 =A0 debug_dump_rings(vq, "found a virtqueue, dumping rings"=
);
> +
> + =A0 =A0 =A0 vq->vq.callback =3D cb;
> + =A0 =A0 =A0 vq->vq.vdev =3D &vdev->vdev;
> +
> + =A0 =A0 =A0 return &vq->vq;
> +}
> +
> +static void vopc_del_vq(struct virtqueue *_vq)
> +{
> + =A0 =A0 =A0 struct vop_vq *vq =3D to_vop_vq(_vq);
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 /* FIXME: make sure that DMA has stopped by this point =
*/
> +
> + =A0 =A0 =A0 /* Unmap and remove all outstanding descriptors from th=
e ring */
> + =A0 =A0 =A0 for (i =3D 0; i < VOP_RING_SIZE; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (vq->data[i]) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "clean=
up detach buffer at index %d\n", i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 detach_buf(vq, i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 debug_dump_rings(vq, "virtqueue destroyed, dumping ring=
s");
> +}
> +
> +/* Read the host's advertised features */
> +static u32 vopc_get_features(struct virtio_device *_vdev)
> +{
> + =A0 =A0 =A0 struct vop_vdev *vdev =3D to_vop_vdev(_vdev);
> + =A0 =A0 =A0 u32 ret;
> +
> + =A0 =A0 =A0 ret =3D vop_get_host_features(vdev);
> + =A0 =A0 =A0 dev_dbg(&vdev->vdev.dev, "%s(): host features 0x%.8x\n"=
, __func__, ret);
> +
> + =A0 =A0 =A0 return ret;
> +}
> +
> +/* At this point, we've chosen whichever features we can use and
> + * put them into the vdev->features array. We should probably notify
> + * the host at this point, but how will virtio react? */
> +static void vopc_finalize_features(struct virtio_device *_vdev)
> +{
> + =A0 =A0 =A0 struct vop_vdev *vdev =3D to_vop_vdev(_vdev);
> + =A0 =A0 =A0 struct device *dev =3D &vdev->vdev.dev;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* TODO: notify the other side at this point
> + =A0 =A0 =A0 =A0*/
> +
> + =A0 =A0 =A0 vdev->guest_status->features[0] =3D cpu_to_le32(vdev->v=
dev.features[0]);
> + =A0 =A0 =A0 dev_dbg(dev, "%s(): final features 0x%.8lx\n", __func__=
, vdev->vdev.features[0]);
> +}
> +
> +static struct virtio_config_ops vop_config_ops =3D {
> + =A0 =A0 =A0 .get =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D vopc_ge=
t,
> + =A0 =A0 =A0 .set =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D vopc_se=
t,
> + =A0 =A0 =A0 .get_status =A0 =A0 =A0 =A0 =A0 =A0 =3D vopc_get_status=
,
> + =A0 =A0 =A0 .set_status =A0 =A0 =A0 =A0 =A0 =A0 =3D vopc_set_status=
,
> + =A0 =A0 =A0 .reset =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D vopc_rese=
t,
> + =A0 =A0 =A0 .find_vq =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D vopc_find_v=
q,
> + =A0 =A0 =A0 .del_vq =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D vopc_del_vq=
,
> + =A0 =A0 =A0 .get_features =A0 =A0 =A0 =A0 =A0 =3D vopc_get_features=
,
> + =A0 =A0 =A0 .finalize_features =A0 =A0 =A0=3D vopc_finalize_feature=
s,
> +};
> +
> +/*------------------------------------------------------------------=
----------*/
> +/* Last-minute device setup code =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> +/*------------------------------------------------------------------=
----------*/
> +
> +/*
> + * Do the last minute setup for virtio_net, now that the host memory=
 is
> + * valid. This includes setting up pointers to the correct queues so=
 that
> + * we can just start the virtqueues when the driver registers
> + */
> +static void setup_virtio_net(struct vop_vdev *vdev)
> +{
> + =A0 =A0 =A0 /* TODO: move some of the setup code from find_vq() her=
e */
> +}
> +
> +/*
> + * Do any last minute setup for a device just before starting it
> + *
> + * The host memory is now valid, so you should be setting up any poi=
nters
> + * the device needs to the host memory
> + */
> +static int vop_setup_device(struct vop_dev *priv, int devnum)
> +{
> + =A0 =A0 =A0 struct vop_vdev *vdev =3D &priv->devices[devnum];
> + =A0 =A0 =A0 struct device *dev =3D priv->dev;
> +
> + =A0 =A0 =A0 if (devnum >=3D ARRAY_SIZE(priv->devices)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(dev, "Unknown virtio_device %d\=
n", devnum);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Setup the device's pointers to host memory */
> + =A0 =A0 =A0 vdev->rem =3D priv->host_mem =A0+ (devnum * 4096);
> + =A0 =A0 =A0 vdev->host_status =3D vdev->rem;
> +
> + =A0 =A0 =A0 switch (devnum) {
> + =A0 =A0 =A0 case 0: /* virtio_net */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 setup_virtio_net(vdev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 default:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(dev, "Device %d not implemented=
\n", devnum);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +/*
> + * Initialize and attempt to register a virtio_device
> + *
> + * @priv the driver data
> + * @devnum the virtio_device number (index into priv->devices)
> + */
> +static int vop_start_device(struct vop_dev *priv, int devnum)
> +{
> + =A0 =A0 =A0 struct vop_vdev *vdev =3D &priv->devices[devnum];
> + =A0 =A0 =A0 struct device *dev =3D priv->dev;
> + =A0 =A0 =A0 int ret;
> +
> + =A0 =A0 =A0 /* Check that we know about the device */
> + =A0 =A0 =A0 if (devnum >=3D ARRAY_SIZE(priv->devices)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(dev, "Unknown virtio_device %d\=
n", devnum);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 vdev->status =3D 0;
> +
> + =A0 =A0 =A0 /* Do any last minute device-specific setup now that th=
e
> + =A0 =A0 =A0 =A0* host memory is valid */
> + =A0 =A0 =A0 ret =3D vop_setup_device(priv, devnum);
> + =A0 =A0 =A0 if (ret) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(dev, "Unable to setup device %d=
\n", devnum);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Register the device with the virtio subsystem */
> + =A0 =A0 =A0 ret =3D register_virtio_device(&vdev->vdev);
> + =A0 =A0 =A0 if (ret) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(dev, "Unable to register device=
 %d\n", devnum);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 vdev->status =3D VOP_DEVICE_REGISTERED;
> + =A0 =A0 =A0 return 0;
> +}
> +
> +/*------------------------------------------------------------------=
----------*/
> +/* Work Functions =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> +/*------------------------------------------------------------------=
----------*/
> +
> +/*
> + * Start as much DMA as we can on the given virtqueue
> + *
> + * This is put on the system shared queue, and will start us much DM=
A as is
> + * available when it is called. This should be triggered when the ho=
st adds
> + * things to the avail rings, and when the guest adds things to the =
internal
> + * avail rings
> + *
> + * Make sure it doesn't sleep for too long, you're on the shared que=
ue
> + */
> +static void vop_dma_work(struct work_struct *work)
> +{
> + =A0 =A0 =A0 struct vop_vq *vq =3D container_of(work, struct vop_vq,=
 work);
> + =A0 =A0 =A0 int ret;
> +
> + =A0 =A0 =A0 /* Start as many DMA transactions as we can, immediatel=
y */
> + =A0 =A0 =A0 while (true) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D vq->resolve(vq);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 }
> +}
> +
> +/*
> + * Remove all virtio devices immediately
> + *
> + * This will be called by the host to make sure that we are in a sto=
pped
> + * state. It should be callable when everything is already stopped.
> + *
> + * Make sure it doesn't sleep for too long, you're on the shared que=
ue
> + */
> +static void vop_reset_work(struct work_struct *work)
> +{
> + =A0 =A0 =A0 struct vop_dev *priv =3D container_of(work, struct vop_=
dev, reset_work);
> + =A0 =A0 =A0 struct device *dev =3D priv->dev;
> + =A0 =A0 =A0 struct vop_vdev *vdev;
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 dev_dbg(dev, "Resetting all virtio devices\n");
> + =A0 =A0 =A0 mutex_lock(&priv->mutex);
> +
> + =A0 =A0 =A0 for (i =3D 0; i < ARRAY_SIZE(priv->devices); i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vdev =3D &priv->devices[i];
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (vdev->status & VOP_DEVICE_REGISTERE=
D) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(dev, "Unregiste=
ring virtio_device #%d\n", i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unregister_virtio_devic=
e(&vdev->vdev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vdev->status &=3D ~VOP_DEVICE_REGISTERE=
D;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (priv->host_mem) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 iounmap(priv->host_mem);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->host_mem =3D NULL;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 mutex_unlock(&priv->mutex);
> +}
> +
> +/*
> + * This will map the host's memory, as well as start the devices tha=
t the host
> + * requested
> + *
> + * Mailbox registers contents:
> + * IMR0 - the host memory physical address (must be <1GB)
> + * IMR1 - the devices the host wants started
> + */
> +static void vop_start_work(struct work_struct *work)
> +{
> + =A0 =A0 =A0 struct vop_dev *priv =3D container_of(work, struct vop_=
dev, start_work);
> + =A0 =A0 =A0 struct device *dev =3D priv->dev;
> + =A0 =A0 =A0 struct vop_vdev *vdev;
> + =A0 =A0 =A0 u32 address, devices;
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 dev_dbg(dev, "Starting requested virtio devices\n");
> + =A0 =A0 =A0 mutex_lock(&priv->mutex);
> +
> + =A0 =A0 =A0 /* Read the requested address and devices from the mail=
box registers */
> + =A0 =A0 =A0 address =3D ioread32(priv->immr + IMR0_OFFSET);
> + =A0 =A0 =A0 devices =3D ioread32(priv->immr + IMR1_OFFSET);
> +
> + =A0 =A0 =A0 dev_dbg(dev, "address 0x%.8x\n", address);
> + =A0 =A0 =A0 dev_dbg(dev, "devices 0x%.8x\n", devices);
> +
> + =A0 =A0 =A0 /* Remap the host's registers */
> + =A0 =A0 =A0 priv->host_mem =3D ioremap(address + 0x80000000, VOP_HO=
ST_MEM_SIZE);
> + =A0 =A0 =A0 if (!priv->host_mem) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(dev, "Unable to ioremap host me=
mory\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_unlock;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Start the requested devices */
> + =A0 =A0 =A0 for (i =3D 0; i < ARRAY_SIZE(priv->devices); i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vdev =3D &priv->devices[i];
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (devices & (1 << i)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(dev, "Starting =
virtio_device #%d\n", i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_start_device(priv, =
i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> +out_unlock:
> + =A0 =A0 =A0 mutex_unlock(&priv->mutex);
> +}
> +
> +/*------------------------------------------------------------------=
----------*/
> +/* Interrupt Handling =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> +/*------------------------------------------------------------------=
----------*/
> +
> +/*
> + * Schedule the work function for a given virtqueue only if the asso=
ciated
> + * device is up and running. Otherwise, ignore the request
> + *
> + * @priv the private driver data
> + * @dev the virtio_device number in priv->devices[]
> + * @queue the virtqueue in vdev->virtqueues[]
> + */
> +static void schedule_work_if_ready(struct vop_dev *priv, int dev, in=
t queue)
> +{
> + =A0 =A0 =A0 struct vop_vdev *vdev =3D &priv->devices[dev];
> + =A0 =A0 =A0 struct vop_vq *vq =3D &vdev->virtqueues[queue];
> +
> + =A0 =A0 =A0 if (vdev->status & VOP_DEVICE_REGISTERED)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule_work(&vq->work);
> +}
> +
> +static irqreturn_t vdev_interrupt(int irq, void *dev_id)
> +{
> + =A0 =A0 =A0 struct vop_dev *priv =3D dev_id;
> + =A0 =A0 =A0 struct device *dev =3D priv->dev;
> + =A0 =A0 =A0 u32 imisr, idr;
> +
> + =A0 =A0 =A0 imisr =3D ioread32(priv->immr + IMISR_OFFSET);
> + =A0 =A0 =A0 idr =A0 =3D ioread32(priv->immr + IDR_OFFSET);
> +
> + =A0 =A0 =A0 dev_dbg(dev, "INTERRUPT idr 0x%.8x\n", idr);
> +
> + =A0 =A0 =A0 /* Check the status register for doorbell interrupts */
> + =A0 =A0 =A0 if (!(imisr & 0x8))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return IRQ_NONE;
> +
> + =A0 =A0 =A0 /* Clear all doorbell interrupts */
> + =A0 =A0 =A0 iowrite32(idr, priv->immr + IDR_OFFSET);
> +
> + =A0 =A0 =A0 /* Reset */
> + =A0 =A0 =A0 if (idr & 0x1)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule_work(&priv->reset_work);
> +
> + =A0 =A0 =A0 /* Start */
> + =A0 =A0 =A0 if (idr & 0x2)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule_work(&priv->start_work);
> +
> + =A0 =A0 =A0 /* vdev 0 vq 1 kick */
> + =A0 =A0 =A0 if (idr & 0x4)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule_work_if_ready(priv, 0, 1);
> +
> + =A0 =A0 =A0 /* vdev 0 vq 0 kick */
> + =A0 =A0 =A0 if (idr & 0x8)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule_work_if_ready(priv, 0, 0);
> +
> + =A0 =A0 =A0 if (idr & 0xfffffff0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(dev, "INTERRUPT unhandled 0x%.8=
x\n", idr & 0xfffffff0);
> +
> + =A0 =A0 =A0 return IRQ_HANDLED;
> +}
> +
> +/*------------------------------------------------------------------=
----------*/
> +/* Driver insertion time virtio device initialization =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> +/*------------------------------------------------------------------=
----------*/
> +
> +static void vdev_release(struct device *dev)
> +{
> + =A0 =A0 =A0 /* TODO: this should probably do something useful */
> + =A0 =A0 =A0 dev_dbg(dev, "%s: called\n", __func__);
> +}
> +
> +/*
> + * Do any device-specific setup for a virtio device
> + *
> + * This would include things like setting the feature bits for the
> + * device, as well as the device type.
> + *
> + * There is no access to host memory at this point, so don't access =
it
> + */
> +static void vop_setup_virtio_device(struct vop_dev *priv, int devnum=
)
> +{
> + =A0 =A0 =A0 struct vop_vdev *vdev =3D &priv->devices[devnum];
> + =A0 =A0 =A0 struct virtio_net_config *config;
> + =A0 =A0 =A0 unsigned long features =3D 0;
> +
> + =A0 =A0 =A0 /* HACK: we only support device #0 (virtio_net) right n=
ow */
> + =A0 =A0 =A0 if (devnum !=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 /* Generate a random ethernet address for the host to h=
ave
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* This way, we could do something board-specific and=
 get an
> + =A0 =A0 =A0 =A0* ethernet address that is consistent per-slot
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 config =3D (struct virtio_net_config *)vdev->guest_stat=
us->config;
> + =A0 =A0 =A0 random_ether_addr(config->mac);
> + =A0 =A0 =A0 dev_info(priv->dev, "Generated MAC %pM\n", config->mac)=
;
> +
> + =A0 =A0 =A0 /* Set the feature bits for the device */
> + =A0 =A0 =A0 set_bit(VIRTIO_NET_F_MAC, =A0 =A0 =A0 &features);
> + =A0 =A0 =A0 set_bit(VIRTIO_NET_F_CSUM, =A0 =A0 =A0&features);
> + =A0 =A0 =A0 set_bit(VIRTIO_NET_F_GSO, =A0 =A0 =A0 &features);
> + =A0 =A0 =A0 set_bit(VIRTIO_NET_F_MRG_RXBUF, &features);
> +
> + =A0 =A0 =A0 vdev->guest_status->features[0] =3D cpu_to_le32(feature=
s);
> + =A0 =A0 =A0 vdev->vdev.id.device =3D VIRTIO_ID_NET;
> +}
> +
> +/*
> + * Do all of the initialization of all of the virtqueues for a given=
 virtio
> + * device. There is no access to host memory at this point, so don't=
 access it
> + *
> + * @devnum the device number in the priv->devices[] array
> + */
> +static void vop_initialize_virtqueues(struct vop_dev *priv, int devn=
um)
> +{
> + =A0 =A0 =A0 struct vop_vdev *vdev =3D &priv->devices[devnum];
> + =A0 =A0 =A0 struct vop_vq *vq;
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 for (i =3D 0; i < ARRAY_SIZE(vdev->virtqueues); i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq =3D &vdev->virtqueues[i];
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memset(vq, 0, sizeof(struct vop_vq));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->immr =3D priv->immr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->dma.chan =3D priv->chan;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 INIT_WORK(&vq->work, vop_dma_work);
> + =A0 =A0 =A0 }
> +}
> +
> +/*
> + * Do all of the initialization for the virtio devices that is possi=
ble without
> + * access to the host memory
> + *
> + * This includes setting up the pointers that you can and setting th=
e feature
> + * bits so that the host can read them before he starts us
> + */
> +static void vop_initialize_devices(struct vop_dev *priv)
> +{
> + =A0 =A0 =A0 struct device *parent =3D priv->dev;
> + =A0 =A0 =A0 struct vop_vdev *vdev;
> + =A0 =A0 =A0 struct device *vdev_dev;
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 for (i =3D 0; i < ARRAY_SIZE(priv->devices); i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vdev =3D &priv->devices[i];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vdev_dev =3D &vdev->vdev.dev;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Set up access to the guest memory, h=
ost memory isn't valid
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* yet, and will have to be set up ju=
st before we start */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vdev->loc =3D priv->guest_mem + (i * 40=
96);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vdev->guest_status =3D vdev->loc;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Initialize all of the device's virtq=
ueues */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_initialize_virtqueues(priv, i);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Zero the configuration space */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memset(vdev->guest_status, 0, 1024);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Copy parent DMA parameters to this d=
evice */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vdev_dev->dma_mask =3D parent->dma_mask=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vdev_dev->dma_parms =3D parent->dma_par=
ms;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vdev_dev->coherent_dma_mask =3D parent-=
>coherent_dma_mask;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vdev_dev->release =3D &vdev_release;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vdev_dev->parent =A0=3D parent;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vdev->vdev.config =3D &vop_config_ops;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Do any device-specific setup */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_setup_virtio_device(priv, i);
> + =A0 =A0 =A0 }
> +}
> +
> +/*------------------------------------------------------------------=
----------*/
> +/* OpenFirmware Device Subsystem =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> +/*------------------------------------------------------------------=
----------*/
> +
> +static int vdev_of_probe(struct of_device *op, const struct of_devic=
e_id *match)
> +{
> + =A0 =A0 =A0 struct vop_dev *priv;
> + =A0 =A0 =A0 dma_cap_mask_t mask;
> + =A0 =A0 =A0 int ret;
> +
> + =A0 =A0 =A0 /* Allocate private data */
> + =A0 =A0 =A0 priv =3D kzalloc(sizeof(*priv), GFP_KERNEL);
> + =A0 =A0 =A0 if (!priv) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&op->dev, "Unable to allocate d=
evice private data\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -ENOMEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_return;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 dev_set_drvdata(&op->dev, priv);
> + =A0 =A0 =A0 priv->dev =3D &op->dev;
> + =A0 =A0 =A0 mutex_init(&priv->mutex);
> + =A0 =A0 =A0 INIT_WORK(&priv->reset_work, vop_reset_work);
> + =A0 =A0 =A0 INIT_WORK(&priv->start_work, vop_start_work);
> +
> + =A0 =A0 =A0 /* Get a DMA channel */
> + =A0 =A0 =A0 dma_cap_zero(mask);
> + =A0 =A0 =A0 dma_cap_set(DMA_MEMCPY, mask);
> + =A0 =A0 =A0 dma_cap_set(DMA_INTERRUPT, mask);
> + =A0 =A0 =A0 priv->chan =3D dma_request_channel(mask, NULL, NULL);
> + =A0 =A0 =A0 if (!priv->chan) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&op->dev, "Unable to get DMA ch=
annel\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -ENODEV;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_free_priv;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Remap IMMR */
> + =A0 =A0 =A0 priv->immr =3D ioremap(get_immrbase(), 0x100000);
> + =A0 =A0 =A0 if (!priv->immr) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&op->dev, "Unable to remap IMMR=
 registers\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -ENOMEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_dma_release_channel;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Set up a static 1GB window into host memory */
> + =A0 =A0 =A0 iowrite32be(LAWAR0_ENABLE | 0x1D, priv->immr + LAWAR0_O=
=46FSET);
> + =A0 =A0 =A0 iowrite32be(POCMR0_ENABLE | 0xC0000, priv->immr + POCMR=
0_OFFSET);
> + =A0 =A0 =A0 iowrite32be(0x0, priv->immr + POTAR0_OFFSET);
> +
> + =A0 =A0 =A0 /* Allocate guest memory */
> + =A0 =A0 =A0 priv->guest_mem =3D dma_alloc_coherent(&op->dev, VOP_GU=
EST_MEM_SIZE,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0&priv->guest_mem_addr, GFP_KERNEL);
> + =A0 =A0 =A0 if (!priv->guest_mem) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&op->dev, "Unable to allocate g=
uest memory\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -ENOMEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_iounmap_immr;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 memset(priv->guest_mem, 0, VOP_GUEST_MEM_SIZE);
> +
> + =A0 =A0 =A0 /* Program BAR1 so that it will hit the guest memory */
> + =A0 =A0 =A0 iowrite32be(priv->guest_mem_addr >> 12, priv->immr + PI=
TAR0_OFFSET);
> +
> + =A0 =A0 =A0 /* Initialize all of the virtio devices with their feat=
ures, etc */
> + =A0 =A0 =A0 vop_initialize_devices(priv);
> +
> + =A0 =A0 =A0 /* Disable mailbox interrupts */
> + =A0 =A0 =A0 iowrite32(0x2 | 0x1, priv->immr + IMIMR_OFFSET);
> +
> + =A0 =A0 =A0 /* Hook up the irq handler */
> + =A0 =A0 =A0 priv->irq =3D irq_of_parse_and_map(op->node, 0);
> + =A0 =A0 =A0 ret =3D request_irq(priv->irq, vdev_interrupt, IRQF_SHA=
RED, driver_name, priv);
> + =A0 =A0 =A0 if (ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_free_guest_mem;
> +
> + =A0 =A0 =A0 dev_info(&op->dev, "Virtio-over-PCI guest driver instal=
led\n");
> + =A0 =A0 =A0 dev_info(&op->dev, "Physical memory @ 0x%.8x\n", priv->=
guest_mem_addr);
> + =A0 =A0 =A0 dev_info(&op->dev, "Descriptor ring size: %d entries\n"=
, VOP_RING_SIZE);
> + =A0 =A0 =A0 return 0;
> +
> +out_free_guest_mem:
> + =A0 =A0 =A0 dma_free_coherent(&op->dev, VOP_GUEST_MEM_SIZE, priv->g=
uest_mem,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->guest_mem_add=
r);
> +out_iounmap_immr:
> + =A0 =A0 =A0 iounmap(priv->immr);
> +out_dma_release_channel:
> + =A0 =A0 =A0 dma_release_channel(priv->chan);
> +out_free_priv:
> + =A0 =A0 =A0 kfree(priv);
> +out_return:
> + =A0 =A0 =A0 return ret;
> +}
> +
> +static int vdev_of_remove(struct of_device *op)
> +{
> + =A0 =A0 =A0 struct vop_dev *priv =3D dev_get_drvdata(&op->dev);
> +
> + =A0 =A0 =A0 /* Stop the irq handler */
> + =A0 =A0 =A0 free_irq(priv->irq, priv);
> +
> + =A0 =A0 =A0 /* Unregister and reset all of the devices */
> + =A0 =A0 =A0 schedule_work(&priv->reset_work);
> + =A0 =A0 =A0 flush_scheduled_work();
> +
> + =A0 =A0 =A0 dma_free_coherent(&op->dev, VOP_GUEST_MEM_SIZE, priv->g=
uest_mem,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->guest_mem_add=
r);
> + =A0 =A0 =A0 iounmap(priv->immr);
> + =A0 =A0 =A0 dma_release_channel(priv->chan);
> + =A0 =A0 =A0 kfree(priv);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static struct of_device_id vdev_of_match[] =3D {
> + =A0 =A0 =A0 { .compatible =3D "fsl,mpc8349-mu", },
> + =A0 =A0 =A0 {},
> +};
> +
> +static struct of_platform_driver vdev_of_driver =3D {
> + =A0 =A0 =A0 .owner =A0 =A0 =A0 =A0 =A0=3D THIS_MODULE,
> + =A0 =A0 =A0 .name =A0 =A0 =A0 =A0 =A0 =3D driver_name,
> + =A0 =A0 =A0 .match_table =A0 =A0=3D vdev_of_match,
> + =A0 =A0 =A0 .probe =A0 =A0 =A0 =A0 =A0=3D vdev_of_probe,
> + =A0 =A0 =A0 .remove =A0 =A0 =A0 =A0 =3D vdev_of_remove,
> +};
> +
> +/*------------------------------------------------------------------=
----------*/
> +/* Module Init / Exit =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> +/*------------------------------------------------------------------=
----------*/
> +
> +static int __init vdev_init(void)
> +{
> + =A0 =A0 =A0 dma_cache =3D KMEM_CACHE(vop_dma_cbinfo, 0);
> + =A0 =A0 =A0 if (!dma_cache) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err("%s: unable to create dma cache\=
n", driver_name);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return of_register_platform_driver(&vdev_of_driver);
> +}
> +
> +static void __exit vdev_exit(void)
> +{
> + =A0 =A0 =A0 of_unregister_platform_driver(&vdev_of_driver);
> + =A0 =A0 =A0 kmem_cache_destroy(dma_cache);
> +}
> +
> +MODULE_AUTHOR("Ira W. Snyder <iws@ovro.caltech.edu>");
> +MODULE_DESCRIPTION("Freescale Virtio-over-PCI Test Driver");
> +MODULE_LICENSE("GPL");
> +
> +module_init(vdev_init);
> +module_exit(vdev_exit);
> diff --git a/drivers/virtio/vop_host.c b/drivers/virtio/vop_host.c
> new file mode 100644
> index 0000000..814fa8a
> --- /dev/null
> +++ b/drivers/virtio/vop_host.c
> @@ -0,0 +1,1071 @@
> +/*
> + * Virtio-over-PCI Host Driver for MPC8349EMDS Guest
> + *
> + * Copyright (c) 2009 Ira W. Snyder <iws@ovro.caltech.edu>
> + *
> + * This file is licensed under the terms of the GNU General Public L=
icense
> + * version 2. This program is licensed "as is" without any warranty =
of any
> + * kind, whether express or implied.
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/init.h>
> +#include <linux/pci.h>
> +#include <linux/virtio.h>
> +#include <linux/virtio_config.h>
> +#include <linux/virtio_net.h>
> +#include <linux/workqueue.h>
> +#include <linux/interrupt.h>
> +
> +#include <linux/etherdevice.h>
> +
> +#include "vop_hw.h"
> +#include "vop.h"
> +
> +static const char driver_name[] =3D "vdev";
> +
> +struct vop_loc_desc {
> + =A0 =A0 =A0 u32 addr;
> + =A0 =A0 =A0 u32 len;
> + =A0 =A0 =A0 u16 flags;
> + =A0 =A0 =A0 u16 next;
> +};
> +
> +struct vop_vq {
> +
> + =A0 =A0 =A0 /* The actual virtqueue itself */
> + =A0 =A0 =A0 struct virtqueue vq;
> +
> + =A0 =A0 =A0 struct device *dev;
> +
> + =A0 =A0 =A0 /* The host ring address */
> + =A0 =A0 =A0 struct vop_host_ring *host;
> +
> + =A0 =A0 =A0 /* The guest ring address */
> + =A0 =A0 =A0 struct vop_guest_ring __iomem *guest;
> +
> + =A0 =A0 =A0 /* Local copy of the descriptors for fast access */
> + =A0 =A0 =A0 struct vop_loc_desc desc[VOP_RING_SIZE];
> +
> + =A0 =A0 =A0 /* The data token from add_buf() */
> + =A0 =A0 =A0 void *data[VOP_RING_SIZE];
> +
> + =A0 =A0 =A0 unsigned int num_free;
> + =A0 =A0 =A0 unsigned int free_head;
> + =A0 =A0 =A0 unsigned int num_added;
> +
> + =A0 =A0 =A0 u16 avail_idx;
> + =A0 =A0 =A0 u16 last_used_idx;
> +
> + =A0 =A0 =A0 /* The doorbell to kick() */
> + =A0 =A0 =A0 unsigned int kick_val;
> + =A0 =A0 =A0 void __iomem *immr;
> +};
> +
> +/* Convert from a struct virtqueue to a struct vop_vq */
> +#define to_vop_vq(X) container_of(X, struct vop_vq, vq)
> +
> +/*
> + * This represents a virtio_device for our driver. It follows the me=
mory
> + * layout shown above. It has pointers to all of the host and guest =
memory
> + * areas that we need to access
> + */
> +struct vop_vdev {
> +
> + =A0 =A0 =A0 /* The specific virtio device (console, net, blk) */
> + =A0 =A0 =A0 struct virtio_device vdev;
> +
> + =A0 =A0 =A0 /* Local and remote memory */
> + =A0 =A0 =A0 void *loc;
> + =A0 =A0 =A0 void __iomem *rem;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* These are the status, feature, and configuration i=
nformation
> + =A0 =A0 =A0 =A0* for this virtio device. They are exposed in our me=
mory block
> + =A0 =A0 =A0 =A0* starting at offset 0.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 struct vop_status *host_status;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* These are the status, feature, and configuration i=
nformation
> + =A0 =A0 =A0 =A0* for the guest virtio device. They are exposed in t=
he guest
> + =A0 =A0 =A0 =A0* memory block starting at offset 0.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 struct vop_status __iomem *guest_status;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* These are the virtqueues for the virtio driver run=
ning this
> + =A0 =A0 =A0 =A0* device to use. The host portions are exposed in ou=
r memory block
> + =A0 =A0 =A0 =A0* starting at offset 1024. The exposed areas are ali=
gned to 1024 byte
> + =A0 =A0 =A0 =A0* boundaries, so they appear at offets 1024, 2048, a=
nd 3072
> + =A0 =A0 =A0 =A0* respectively.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 struct vop_vq virtqueues[3];
> +};
> +
> +#define to_vop_vdev(X) container_of(X, struct vop_vdev, vdev)
> +
> +/*
> + * This is information from the PCI subsystem about each MPC8349EMDS=
 board
> + *
> + * It holds information for all of the possible virtio_devices that =
are
> + * attached to this board.
> + */
> +struct vop_dev {
> +
> + =A0 =A0 =A0 struct pci_dev *pdev;
> + =A0 =A0 =A0 struct device *dev;
> +
> + =A0 =A0 =A0 /* PowerPC memory (PCI BAR0 and BAR1, respectively) */
> + =A0 =A0 =A0 #define VOP_GUEST_MEM_SIZE 16384
> + =A0 =A0 =A0 void __iomem *immr;
> + =A0 =A0 =A0 void __iomem *netregs;
> +
> + =A0 =A0 =A0 /* Host memory, visible to the PowerPC */
> + =A0 =A0 =A0 #define VOP_HOST_MEM_SIZE 16384
> + =A0 =A0 =A0 void *host_mem;
> + =A0 =A0 =A0 dma_addr_t host_mem_addr;
> +
> + =A0 =A0 =A0 /* The virtio devices */
> + =A0 =A0 =A0 struct vop_vdev devices[4];
> +};
> +
> +/*------------------------------------------------------------------=
----------*/
> +/* Ring Debugging Helpers =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> +/*------------------------------------------------------------------=
----------*/
> +
> +#ifdef DEBUG_DUMP_RINGS
> +static void dump_guest_descriptors(struct vop_vq *vq)
> +{
> + =A0 =A0 =A0 int i;
> + =A0 =A0 =A0 struct vop_desc __iomem *desc;
> +
> + =A0 =A0 =A0 pr_debug("DESC BG: 0xADDRESSX LENGTH 0xFLAG 0xNEXT\n");
> + =A0 =A0 =A0 for (i =3D 0; i < VOP_RING_SIZE; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 desc =3D &vq->guest->desc[i];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debug("DESC %.2d: 0x%.8x %.6d 0x%.4x=
 0x%.4x\n", i,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioread3=
2(&desc->addr), ioread32(&desc->len),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioread1=
6(&desc->flags), ioread16(&desc->next));
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 pr_debug("DESC ED\n");
> +}
> +
> +static void dump_guest_avail(struct vop_vq *vq)
> +{
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 pr_debug("BEGIN AVAIL DUMP\n");
> + =A0 =A0 =A0 for (i =3D 0; i < VOP_RING_SIZE; i++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debug("AVAIL %.2d: 0x%.4x\n", i, ior=
ead16(&vq->guest->avail[i]));
> + =A0 =A0 =A0 pr_debug("END AVAIL DUMP\n");
> +}
> +
> +static void dump_guest_ring(struct vop_vq *vq)
> +{
> + =A0 =A0 =A0 pr_debug("BEGIN GUEST RING DUMP\n");
> + =A0 =A0 =A0 dump_guest_descriptors(vq);
> + =A0 =A0 =A0 pr_debug("GUEST FLAGS: 0x%.4x\n", ioread16(&vq->guest->=
flags));
> + =A0 =A0 =A0 pr_debug("GUEST AVAIL_IDX: %d\n", ioread16(&vq->guest->=
avail_idx));
> + =A0 =A0 =A0 dump_guest_avail(vq);
> + =A0 =A0 =A0 pr_debug("END GUEST RING DUMP\n");
> +}
> +
> +static void dump_host_used(struct vop_vq *vq)
> +{
> + =A0 =A0 =A0 int i;
> + =A0 =A0 =A0 struct vop_used_elem *used;
> +
> + =A0 =A0 =A0 pr_debug("USED BG: 0xIDID LENGTH\n");
> + =A0 =A0 =A0 for (i =3D 0; i < VOP_RING_SIZE; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 used =3D &vq->host->used[i];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debug("USED %.2d: 0x%.4x %.6d\n", i,=
 used->id, used->len);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 pr_debug("USED ED\n");
> +}
> +
> +static void dump_host_ring(struct vop_vq *vq)
> +{
> + =A0 =A0 =A0 pr_debug("BEGIN HOST RING DUMP\n");
> + =A0 =A0 =A0 pr_debug("HOST FLAGS: 0x%.4x\n", vq->host->flags);
> + =A0 =A0 =A0 pr_debug("HOST USED_IDX: 0x%.2d\n", vq->host->used_idx)=
;
> + =A0 =A0 =A0 dump_host_used(vq);
> + =A0 =A0 =A0 pr_debug("END HOST RING DUMP\n");
> +}
> +
> +static void debug_dump_rings(struct vop_vq *vq, const char *msg)
> +{
> + =A0 =A0 =A0 dev_dbg(vq->dev, "%s\n", msg);
> + =A0 =A0 =A0 dump_guest_ring(vq);
> + =A0 =A0 =A0 dump_host_ring(vq);
> + =A0 =A0 =A0 pr_debug("\n");
> +}
> +#else
> +static void debug_dump_rings(struct vop_vq *vq, const char *msg)
> +{
> + =A0 =A0 =A0 /* Nothing */
> +}
> +#endif /* DEBUG_DUMP_RINGS */
> +
> +/*------------------------------------------------------------------=
----------*/
> +/* Ring Access Helpers =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> +/*------------------------------------------------------------------=
----------*/
> +
> +static void vop_set_desc_addr(struct vop_vq *vq, unsigned int idx, u=
32 addr)
> +{
> + =A0 =A0 =A0 vq->desc[idx].addr =3D addr;
> + =A0 =A0 =A0 iowrite32(addr, &vq->guest->desc[idx].addr);
> +}
> +
> +static void vop_set_desc_len(struct vop_vq *vq, unsigned int idx, u3=
2 len)
> +{
> + =A0 =A0 =A0 vq->desc[idx].len =3D len;
> + =A0 =A0 =A0 iowrite32(len, &vq->guest->desc[idx].len);
> +}
> +
> +static void vop_set_desc_flags(struct vop_vq *vq, unsigned int idx, =
u16 flags)
> +{
> + =A0 =A0 =A0 vq->desc[idx].flags =3D flags;
> + =A0 =A0 =A0 iowrite16(flags, &vq->guest->desc[idx].flags);
> +}
> +
> +static void vop_set_desc_next(struct vop_vq *vq, unsigned int idx, u=
16 next)
> +{
> + =A0 =A0 =A0 vq->desc[idx].next =3D next;
> + =A0 =A0 =A0 iowrite16(next, &vq->guest->desc[idx].next);
> +}
> +
> +static u32 vop_get_desc_addr(struct vop_vq *vq, unsigned int idx)
> +{
> + =A0 =A0 =A0 return vq->desc[idx].addr;
> +}
> +
> +static u32 vop_get_desc_len(struct vop_vq *vq, unsigned int idx)
> +{
> + =A0 =A0 =A0 return vq->desc[idx].len;
> +}
> +
> +static u16 vop_get_desc_flags(struct vop_vq *vq, unsigned int idx)
> +{
> + =A0 =A0 =A0 return vq->desc[idx].flags;
> +}
> +
> +static u16 vop_get_desc_next(struct vop_vq *vq, unsigned int idx)
> +{
> + =A0 =A0 =A0 return vq->desc[idx].next;
> +}
> +
> +/*
> + * Add an entry to the available ring at avail_idx pointing to the d=
escriptor
> + * chain at index head
> + *
> + * @vq the virtqueue
> + * @idx the index in the avail ring
> + * @val the value to write
> + */
> +static void vop_set_avail_entry(struct vop_vq *vq, u16 idx, u16 val)
> +{
> + =A0 =A0 =A0 iowrite16(val, &vq->guest->avail[idx]);
> +}
> +
> +/*
> + * Set the available index so the guest knows about buffers that wer=
e added
> + * with vop_set_avail_entry()
> + *
> + * @vq the virtqueue
> + * @idx the new avail_idx that the guest sees
> + */
> +static void vop_set_avail_idx(struct vop_vq *vq, u16 idx)
> +{
> + =A0 =A0 =A0 iowrite16(idx, &vq->guest->avail_idx);
> +}
> +
> +/*
> + * Set the host's flags (in the guest memory)
> + *
> + * @vq the virtqueue
> + * @flags the new flags that the guest will see
> + */
> +static void vop_set_host_flags(struct vop_vq *vq, u16 flags)
> +{
> + =A0 =A0 =A0 iowrite16(flags, &vq->guest->flags);
> +}
> +
> +/*
> + * Read the guests flags (in local memory)
> + *
> + * @vq the virtqueue
> + * @return the guest's flags
> + */
> +static u16 vop_get_guest_flags(struct vop_vq *vq)
> +{
> + =A0 =A0 =A0 return le16_to_cpu(vq->host->flags);
> +}
> +
> +/*------------------------------------------------------------------=
----------*/
> +/* Remote status helpers =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> +/*------------------------------------------------------------------=
----------*/
> +
> +static u32 vop_get_guest_status(struct vop_vdev *vdev)
> +{
> + =A0 =A0 =A0 return ioread32(&vdev->guest_status->status);
> +}
> +
> +static u32 vop_get_guest_features(struct vop_vdev *vdev)
> +{
> + =A0 =A0 =A0 return ioread32(&vdev->guest_status->features[0]);
> +}
> +
> +/*------------------------------------------------------------------=
----------*/
> +/* Scatterlist DMA helpers =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> +/*------------------------------------------------------------------=
----------*/
> +
> +/*
> + * This function abuses some of the scatterlist code and implements
> + * dma_map_sg() in such a way that we don't need to keep the scatter=
list
> + * around in order to unmap it.
> + *
> + * It is also designed to never merge scatterlist entries, which is
> + * never what we want for virtio.
> + *
> + * When it is time to unmap the buffer, you can use dma_unmap_single=
() to
> + * unmap each entry in the chain. Get the address, length, and direc=
tion
> + * from the descriptors! (keep a local copy for speed)
> + */
> +static int vop_dma_map_sg(struct device *dev, struct scatterlist sg[=
],
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int out, u=
nsigned int in)
> +{
> + =A0 =A0 =A0 dma_addr_t addr;
> + =A0 =A0 =A0 enum dma_data_direction dir;
> + =A0 =A0 =A0 struct scatterlist *start;
> + =A0 =A0 =A0 unsigned int i, failure;
> +
> + =A0 =A0 =A0 start =3D sg;
> +
> + =A0 =A0 =A0 for (i =3D 0; i < out + in; i++) {
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Check for scatterlist chaining abuse=
 */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(sg =3D=3D NULL);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dir =3D (i < out) ? DMA_TO_DEVICE : DMA=
_FROM_DEVICE;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 addr =3D dma_map_single(dev, sg_virt(sg=
), sg->length, dir);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (dma_mapping_error(dev, addr))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto unwind;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sg_dma_address(sg) =3D addr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sg =3D sg_next(sg);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return 0;
> +
> +unwind:
> + =A0 =A0 =A0 failure =3D i;
> + =A0 =A0 =A0 sg =3D start;
> +
> + =A0 =A0 =A0 for (i =3D 0; i < failure; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dir =3D (i < out) ? DMA_TO_DEVICE : DMA=
_FROM_DEVICE;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 addr =3D sg_dma_address(sg);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma_unmap_single(dev, addr, sg->length,=
 dir);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sg =3D sg_next(sg);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return -ENOMEM;
> +}
> +
> +/*------------------------------------------------------------------=
----------*/
> +/* struct virtqueue_ops infrastructure =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> +/*------------------------------------------------------------------=
----------*/
> +
> +/*
> + * Modify the struct virtio_net_hdr_mrg_rxbuf's num_buffers field to=
 account
> + * for the split that will happen in the DMA xmit routine
> + *
> + * This assumes that both sides have the same PAGE_SIZE
> + */
> +static void vop_fixup_vnet_mrg_hdr(struct scatterlist sg[], unsigned=
 int out)
> +{
> + =A0 =A0 =A0 struct virtio_net_hdr *hdr;
> + =A0 =A0 =A0 struct virtio_net_hdr_mrg_rxbuf *mhdr;
> + =A0 =A0 =A0 unsigned int bytes =3D 0;
> +
> + =A0 =A0 =A0 /* There must be a header + data, at the least */
> + =A0 =A0 =A0 BUG_ON(out < 2);
> +
> + =A0 =A0 =A0 /* The first entry must be the structure */
> + =A0 =A0 =A0 BUG_ON(sg->length !=3D sizeof(struct virtio_net_hdr_mrg=
_rxbuf));
> +
> + =A0 =A0 =A0 hdr =3D sg_virt(sg);
> + =A0 =A0 =A0 mhdr =3D sg_virt(sg);
> +
> + =A0 =A0 =A0 /* We merge buffers together, so just count up the numb=
er of bytes
> + =A0 =A0 =A0 =A0* needed, then figure out how many pages that will b=
e */
> + =A0 =A0 =A0 for (/* none */; out; out--, sg =3D sg_next(sg))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bytes +=3D sg->length;
> +
> + =A0 =A0 =A0 /* Of course, nobody ever imagined that we might actual=
ly use
> + =A0 =A0 =A0 =A0* this on machines with different endianness...
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* We force big-endian for now, since that's what our=
 guest is */
> + =A0 =A0 =A0 mhdr->num_buffers =3D cpu_to_be16(DIV_ROUND_UP(bytes, P=
AGE_SIZE));
> +
> + =A0 =A0 =A0 /* Might as well fix up the other fields while we're at=
 it */
> + =A0 =A0 =A0 hdr->hdr_len =3D cpu_to_be16(hdr->hdr_len);
> + =A0 =A0 =A0 hdr->gso_size =3D cpu_to_be16(hdr->gso_size);
> + =A0 =A0 =A0 hdr->csum_start =3D cpu_to_be16(hdr->csum_start);
> + =A0 =A0 =A0 hdr->csum_offset =3D cpu_to_be16(hdr->csum_offset);
> +}
> +
> +static int vop_add_buf(struct virtqueue *_vq, struct scatterlist sg[=
],
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigne=
d int out, unsigned int in, void *data)
> +{
> + =A0 =A0 =A0 struct vop_vq *vq =3D to_vop_vq(_vq);
> + =A0 =A0 =A0 unsigned int i, avail, head, uninitialized_var(prev);
> +
> + =A0 =A0 =A0 BUG_ON(data =3D=3D NULL);
> + =A0 =A0 =A0 BUG_ON(out + in =3D=3D 0);
> +
> + =A0 =A0 =A0 /* Make sure we have space for this to succeed */
> + =A0 =A0 =A0 if (vq->num_free < out + in) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "No free space left: l=
en=3D%d free=3D%d\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 out + i=
n, vq->num_free);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOSPC;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* If this is an xmit buffer from virtio_net, fixup the=
 header */
> + =A0 =A0 =A0 if (out > 1) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "Fixing up virtio_net =
header\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_fixup_vnet_mrg_hdr(sg, out);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 head =3D vq->free_head;
> +
> + =A0 =A0 =A0 /* DMA map the scatterlist */
> + =A0 =A0 =A0 if (vop_dma_map_sg(vq->dev, sg, out, in)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(vq->dev, "Failed to DMA map sca=
tterlist\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* We're about to use some buffers from the free list *=
/
> + =A0 =A0 =A0 vq->num_free -=3D out + in;
> +
> + =A0 =A0 =A0 for (i =3D vq->free_head; out; i =3D vop_get_desc_next(=
vq, i), out--) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_set_desc_flags(vq, i, VOP_DESC_F_NE=
XT);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_set_desc_addr(vq, i, sg_dma_address=
(sg));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_set_desc_len(vq, i, sg->length);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 prev =3D i;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sg =3D sg_next(sg);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 for (/* none */; in; i =3D vop_get_desc_next(vq, i), in=
--) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_set_desc_flags(vq, i, VOP_DESC_F_NE=
XT | VOP_DESC_F_WRITE);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_set_desc_addr(vq, i, sg_dma_address=
(sg));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_set_desc_len(vq, i, sg->length);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 prev =3D i;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sg =3D sg_next(sg);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Last one doesn't continue */
> + =A0 =A0 =A0 vop_set_desc_flags(vq, prev, vop_get_desc_flags(vq, pre=
v) & ~VOP_DESC_F_NEXT);
> +
> + =A0 =A0 =A0 /* Update the free pointer */
> + =A0 =A0 =A0 vq->free_head =3D i;
> +
> + =A0 =A0 =A0 /* Set token */
> + =A0 =A0 =A0 vq->data[head] =3D data;
> +
> + =A0 =A0 =A0 /* Add an entry for the head of the chain into the avai=
l array, but
> + =A0 =A0 =A0 =A0* don't update avail->idx until kick() */
> + =A0 =A0 =A0 avail =3D (vq->avail_idx + vq->num_added++) & (VOP_RING=
_SIZE - 1);
> + =A0 =A0 =A0 vop_set_avail_entry(vq, avail, head);
> +
> + =A0 =A0 =A0 dev_dbg(vq->dev, "Added buffer head %i to %p (num_free =
%d)\n", head, vq, vq->num_free);
> + =A0 =A0 =A0 debug_dump_rings(vq, "Added buffer(s), dumping rings");
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static inline bool more_used(const struct vop_vq *vq)
> +{
> + =A0 =A0 =A0 return vq->last_used_idx !=3D le16_to_cpu(vq->host->use=
d_idx);
> +}
> +
> +static void detach_buf(struct vop_vq *vq, unsigned int head)
> +{
> + =A0 =A0 =A0 unsigned int i, len;
> + =A0 =A0 =A0 dma_addr_t addr;
> + =A0 =A0 =A0 enum dma_data_direction dir;
> +
> + =A0 =A0 =A0 /* Clear data pointer */
> + =A0 =A0 =A0 vq->data[head] =3D NULL;
> +
> + =A0 =A0 =A0 /* Put the chain back on the free list, unmapping as we=
 go */
> + =A0 =A0 =A0 i =3D head;
> + =A0 =A0 =A0 while (true) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 addr =3D vop_get_desc_addr(vq, i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 len =3D vop_get_desc_len(vq, i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dir =3D (vop_get_desc_flags(vq, i) & VO=
P_DESC_F_WRITE) ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 DMA_FRO=
M_DEVICE : DMA_TO_DEVICE;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Unmap the entry */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma_unmap_single(vq->dev, addr, len, di=
r);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->num_free++;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Check for end-of-chain */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(vop_get_desc_flags(vq, i) & VOP_D=
ESC_F_NEXT))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 i =3D vop_get_desc_next(vq, i);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 vop_set_desc_next(vq, i, vq->free_head);
> + =A0 =A0 =A0 vq->free_head =3D head;
> +}
> +
> +static void *vop_get_buf(struct virtqueue *_vq, unsigned int *len)
> +{
> + =A0 =A0 =A0 struct vop_vq *vq =3D to_vop_vq(_vq);
> + =A0 =A0 =A0 unsigned int head, used_idx;
> + =A0 =A0 =A0 void *ret;
> +
> + =A0 =A0 =A0 if (!more_used(vq)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "No more buffers in qu=
eue\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 used_idx =3D vq->last_used_idx & (VOP_RING_SIZE - 1);
> + =A0 =A0 =A0 head =3D le32_to_cpu(vq->host->used[used_idx].id);
> + =A0 =A0 =A0 *len =3D le32_to_cpu(vq->host->used[used_idx].len);
> +
> + =A0 =A0 =A0 dev_dbg(vq->dev, "REMOVE buffer head %i from %p (len %d=
)\n", head, vq, *len);
> + =A0 =A0 =A0 debug_dump_rings(vq, "Removing buffer, dumping rings");
> +
> + =A0 =A0 =A0 BUG_ON(head >=3D VOP_RING_SIZE);
> + =A0 =A0 =A0 BUG_ON(!vq->data[head]);
> +
> + =A0 =A0 =A0 /* detach_buf() clears data, save it now */
> + =A0 =A0 =A0 ret =3D vq->data[head];
> + =A0 =A0 =A0 detach_buf(vq, head);
> +
> + =A0 =A0 =A0 /* Update the last used_idx we've consumed */
> + =A0 =A0 =A0 vq->last_used_idx++;
> + =A0 =A0 =A0 return ret;
> +}
> +
> +static void vop_kick(struct virtqueue *_vq)
> +{
> + =A0 =A0 =A0 struct vop_vq *vq =3D to_vop_vq(_vq);
> +
> + =A0 =A0 =A0 dev_dbg(vq->dev, "making %d new buffers available to gu=
est\n", vq->num_added);
> + =A0 =A0 =A0 vq->avail_idx +=3D vq->num_added;
> + =A0 =A0 =A0 vq->num_added =3D 0;
> + =A0 =A0 =A0 vop_set_avail_idx(vq, vq->avail_idx);
> +
> + =A0 =A0 =A0 if (!(vop_get_guest_flags(vq) & VOP_F_NO_INTERRUPT)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "kicking the guest (ne=
w buffers in avail)\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 iowrite32(vq->kick_val, vq->immr + IDR_=
OFFSET);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 debug_dump_rings(vq, "ran a kick, dumpi=
ng rings");
> + =A0 =A0 =A0 }
> +}
> +
> +/* Write to the guest's flags register to disable interrupts */
> +static void vop_disable_cb(struct virtqueue *_vq)
> +{
> + =A0 =A0 =A0 struct vop_vq *vq =3D to_vop_vq(_vq);
> +
> + =A0 =A0 =A0 vop_set_host_flags(vq, VOP_F_NO_INTERRUPT);
> +}
> +
> +static bool vop_enable_cb(struct virtqueue *_vq)
> +{
> + =A0 =A0 =A0 struct vop_vq *vq =3D to_vop_vq(_vq);
> +
> + =A0 =A0 =A0 /* We optimistically enable interrupts, then check if
> + =A0 =A0 =A0 =A0* there was more to do */
> + =A0 =A0 =A0 vop_set_host_flags(vq, 0);
> +
> + =A0 =A0 =A0 if (unlikely(more_used(vq)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> +
> + =A0 =A0 =A0 return true;
> +}
> +
> +static struct virtqueue_ops vop_vq_ops =3D {
> + =A0 =A0 =A0 .add_buf =A0 =A0 =A0 =A0=3D vop_add_buf,
> + =A0 =A0 =A0 .get_buf =A0 =A0 =A0 =A0=3D vop_get_buf,
> + =A0 =A0 =A0 .kick =A0 =A0 =A0 =A0 =A0 =3D vop_kick,
> + =A0 =A0 =A0 .disable_cb =A0 =A0 =3D vop_disable_cb,
> + =A0 =A0 =A0 .enable_cb =A0 =A0 =A0=3D vop_enable_cb,
> +};
> +
> +/*------------------------------------------------------------------=
----------*/
> +/* struct virtio_device infrastructure =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> +/*------------------------------------------------------------------=
----------*/
> +
> +/* Get something that the other side wants you to have, from configu=
ration
> + * space. This is used to transfer the MAC address from the guest to=
 the host,
> + * for example. It should be reading something from the guest, in th=
is case */
> +static void vopc_get(struct virtio_device *_vdev, unsigned offset, v=
oid *buf,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned len)
> +{
> + =A0 =A0 =A0 struct vop_vdev *vdev =3D to_vop_vdev(_vdev);
> + =A0 =A0 =A0 void __iomem *config =3D vdev->guest_status->config;
> +
> + =A0 =A0 =A0 memcpy_fromio(buf, config + offset, len);
> +}
> +
> +/* Set something in the configuration space (currently unused) */
> +static void vopc_set(struct virtio_device *_vdev, unsigned offset,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const void *buf, unsigned le=
n)
> +{
> + =A0 =A0 =A0 struct vop_vdev *vdev =3D to_vop_vdev(_vdev);
> + =A0 =A0 =A0 void __iomem *config =3D vdev->guest_status->config;
> +
> + =A0 =A0 =A0 memcpy_toio(config + offset, buf, len);
> +}
> +
> +/* Get your own status */
> +static u8 vopc_get_status(struct virtio_device *_vdev)
> +{
> + =A0 =A0 =A0 struct vop_vdev *vdev =3D to_vop_vdev(_vdev);
> + =A0 =A0 =A0 u32 status;
> +
> + =A0 =A0 =A0 status =3D le32_to_cpu(vdev->host_status->status);
> + =A0 =A0 =A0 dev_dbg(&vdev->vdev.dev, "%s(): -> 0x%.2x\n", __func__,=
 (u8)status);
> +
> + =A0 =A0 =A0 return (u8)status;
> +}
> +
> +/* Set your own status */
> +static void vopc_set_status(struct virtio_device *_vdev, u8 status)
> +{
> + =A0 =A0 =A0 struct vop_vdev *vdev =3D to_vop_vdev(_vdev);
> + =A0 =A0 =A0 u32 old_status;
> +
> + =A0 =A0 =A0 old_status =3D le32_to_cpu(vdev->host_status->status);
> + =A0 =A0 =A0 vdev->host_status->status =3D cpu_to_le32(status);
> +
> + =A0 =A0 =A0 dev_dbg(&vdev->vdev.dev, "%s(): <- 0x%.2x (was 0x%.2x)\=
n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __func__, status, old_s=
tatus);
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* FIXME: we really need to notify the other side whe=
n status changes
> + =A0 =A0 =A0 =A0* FIXME: happen, so that they can take some action
> + =A0 =A0 =A0 =A0*/
> +}
> +
> +/* Reset your own status */
> +static void vopc_reset(struct virtio_device *_vdev)
> +{
> + =A0 =A0 =A0 struct vop_vdev *vdev =3D to_vop_vdev(_vdev);
> +
> + =A0 =A0 =A0 dev_dbg(&vdev->vdev.dev, "%s(): status reset\n", __func=
__);
> + =A0 =A0 =A0 vdev->host_status->status =3D cpu_to_le32(0);
> +}
> +
> +static struct virtqueue *vopc_find_vq(struct virtio_device *_vdev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0unsigned index,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0void (*cb)(struct virtqueue *vq))
> +{
> + =A0 =A0 =A0 struct vop_vdev *vdev =3D to_vop_vdev(_vdev);
> + =A0 =A0 =A0 struct vop_vq *vq =3D &vdev->virtqueues[index];
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 /* Check that we support the virtqueue at this index */
> + =A0 =A0 =A0 if (index >=3D ARRAY_SIZE(vdev->virtqueues)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&vdev->vdev.dev, "no virtqueue =
for index %d\n", index);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-ENODEV);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* HACK: we only support virtio_net for now */
> + =A0 =A0 =A0 if (vdev->vdev.id.device !=3D VIRTIO_ID_NET) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&vdev->vdev.dev, "only virtio_n=
et is supported\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-ENODEV);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Initialize the virtqueue to a clean state */
> + =A0 =A0 =A0 vq->num_free =3D VOP_RING_SIZE;
> + =A0 =A0 =A0 vq->dev =3D &vdev->vdev.dev;
> +
> + =A0 =A0 =A0 switch (index) {
> + =A0 =A0 =A0 case 0: /* x86 recv virtqueue -- ppc xmit virtqueue */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->guest =3D vdev->rem + 1024;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->host =A0=3D vdev->loc + 1024;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 case 1: /* x86 xmit virtqueue -- ppc recv virtqueue */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->guest =3D vdev->rem + 2048;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->host =A0=3D vdev->loc + 2048;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 default:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(vq->dev, "unknown virtqueue %d\=
n", index);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-ENODEV);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Initialize the descriptor, avail, and used rings */
> + =A0 =A0 =A0 for (i =3D 0; i < VOP_RING_SIZE; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_set_desc_addr(vq, i, 0x0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_set_desc_len(vq, i, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_set_desc_flags(vq, i, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_set_desc_next(vq, i, (i + 1) & (VOP=
_RING_SIZE - 1));
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vop_set_avail_entry(vq, i, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->host->used[i].id =3D cpu_to_le32(0)=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->host->used[i].len =3D cpu_to_le32(0=
);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 vq->avail_idx =3D 0;
> + =A0 =A0 =A0 vop_set_avail_idx(vq, 0);
> + =A0 =A0 =A0 vop_set_host_flags(vq, 0);
> +
> + =A0 =A0 =A0 debug_dump_rings(vq, "found a virtqueue, dumping rings"=
);
> +
> + =A0 =A0 =A0 vq->vq.callback =3D cb;
> + =A0 =A0 =A0 vq->vq.vdev =3D &vdev->vdev;
> + =A0 =A0 =A0 vq->vq.vq_ops =3D &vop_vq_ops;
> +
> + =A0 =A0 =A0 return &vq->vq;
> +}
> +
> +static void vopc_del_vq(struct virtqueue *_vq)
> +{
> + =A0 =A0 =A0 struct vop_vq *vq =3D to_vop_vq(_vq);
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 /* FIXME: make sure that DMA has stopped by this point =
*/
> +
> + =A0 =A0 =A0 /* Unmap and remove all outstanding descriptors from th=
e ring */
> + =A0 =A0 =A0 for (i =3D 0; i < VOP_RING_SIZE; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (vq->data[i]) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(vq->dev, "clean=
up detach buffer at index %d\n", i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 detach_buf(vq, i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 debug_dump_rings(vq, "virtqueue destroyed, dumping ring=
s");
> +}
> +
> +static u32 vopc_get_features(struct virtio_device *_vdev)
> +{
> + =A0 =A0 =A0 struct vop_vdev *vdev =3D to_vop_vdev(_vdev);
> + =A0 =A0 =A0 u32 ret;
> +
> + =A0 =A0 =A0 ret =3D vop_get_guest_features(vdev);
> + =A0 =A0 =A0 dev_info(&vdev->vdev.dev, "%s(): guest features 0x%.8x\=
n", __func__, ret);
> +
> + =A0 =A0 =A0 return ret;
> +}
> +
> +static void vopc_finalize_features(struct virtio_device *_vdev)
> +{
> + =A0 =A0 =A0 struct vop_vdev *vdev =3D to_vop_vdev(_vdev);
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* TODO: notify the other side at this point
> + =A0 =A0 =A0 =A0*/
> +
> + =A0 =A0 =A0 vdev->host_status->features[0] =3D cpu_to_le32(vdev->vd=
ev.features[0]);
> + =A0 =A0 =A0 dev_info(&vdev->vdev.dev, "%s(): final features 0x%.8lx=
\n", __func__, vdev->vdev.features[0]);
> +}
> +
> +static struct virtio_config_ops vop_config_ops =3D {
> + =A0 =A0 =A0 .get =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D vopc_ge=
t,
> + =A0 =A0 =A0 .set =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D vopc_se=
t,
> + =A0 =A0 =A0 .get_status =A0 =A0 =A0 =A0 =A0 =A0 =3D vopc_get_status=
,
> + =A0 =A0 =A0 .set_status =A0 =A0 =A0 =A0 =A0 =A0 =3D vopc_set_status=
,
> + =A0 =A0 =A0 .reset =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D vopc_rese=
t,
> + =A0 =A0 =A0 .find_vq =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D vopc_find_v=
q,
> + =A0 =A0 =A0 .del_vq =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D vopc_del_vq=
,
> + =A0 =A0 =A0 .get_features =A0 =A0 =A0 =A0 =A0 =3D vopc_get_features=
,
> + =A0 =A0 =A0 .finalize_features =A0 =A0 =A0=3D vopc_finalize_feature=
s,
> +};
> +
> +/*------------------------------------------------------------------=
----------*/
> +/* Setup code for virtio devices =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> +/*------------------------------------------------------------------=
----------*/
> +
> +static void vop_release(struct device *dev)
> +{
> + =A0 =A0 =A0 dev_dbg(dev, "calling device release\n");
> +}
> +
> +static int setup_virtio_device(struct vop_dev *priv, int devnum)
> +{
> + =A0 =A0 =A0 struct vop_vdev *vdev =3D &priv->devices[devnum];
> + =A0 =A0 =A0 struct device *dev =3D priv->dev;
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 /* Set up the pointers to the guest and host memory are=
as */
> + =A0 =A0 =A0 vdev->loc =3D priv->host_mem + (devnum * 4096);
> + =A0 =A0 =A0 vdev->rem =3D priv->netregs =A0+ (devnum * 4096);
> + =A0 =A0 =A0 dev_dbg(dev, "memory guest 0x%p host 0x%p\n", vdev->rem=
, vdev->loc);
> +
> + =A0 =A0 =A0 /* Set up the pointers to the guest and host status are=
as */
> + =A0 =A0 =A0 vdev->guest_status =3D vdev->rem;
> + =A0 =A0 =A0 vdev->host_status =A0=3D vdev->loc;
> + =A0 =A0 =A0 dev_dbg(dev, "status guest 0x%p host 0x%p\n", vdev->rem=
, vdev->loc);
> +
> + =A0 =A0 =A0 /* The find_vq() must set up the correct mappings to vi=
rtqueues itself,
> + =A0 =A0 =A0 =A0* so we cannot do it here */
> + =A0 =A0 =A0 for (i =3D 0; i < ARRAY_SIZE(vdev->virtqueues); i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memset(&vdev->virtqueues[i], 0, sizeof(=
struct vop_vq));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vdev->virtqueues[i].immr =3D priv->immr=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vdev->virtqueues[i].kick_val =3D 1 << (=
(devnum * 4) + i + 2);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(dev, "vq %d cleared, kick %d\n"=
, i, (devnum * 4) + i + 2);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Zero out the configuration space completely */
> + =A0 =A0 =A0 memset(vdev->host_status, 0, 1024);
> +
> + =A0 =A0 =A0 /* Copy the parent DMA parameters to this virtio_device=
 */
> + =A0 =A0 =A0 vdev->vdev.dev.dma_mask =3D dev->dma_mask;
> + =A0 =A0 =A0 vdev->vdev.dev.dma_parms =3D dev->dma_parms;
> + =A0 =A0 =A0 vdev->vdev.dev.coherent_dma_mask =3D dev->coherent_dma_=
mask;
> +
> + =A0 =A0 =A0 /* Setup everything except the device type */
> + =A0 =A0 =A0 vdev->vdev.dev.release =3D &vop_release;
> + =A0 =A0 =A0 vdev->vdev.dev.parent =A0=3D dev;
> + =A0 =A0 =A0 vdev->vdev.config =A0 =A0 =A0=3D &vop_config_ops;
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int register_virtio_net(struct vop_dev *priv)
> +{
> + =A0 =A0 =A0 struct vop_vdev *vdev =3D &priv->devices[0];
> + =A0 =A0 =A0 struct virtio_net_config *config;
> + =A0 =A0 =A0 unsigned long features =3D 0;
> + =A0 =A0 =A0 int ret;
> +
> + =A0 =A0 =A0 /* Run the common setup routine */
> + =A0 =A0 =A0 ret =3D setup_virtio_device(priv, 0);
> + =A0 =A0 =A0 if (ret) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(priv->dev, "unable to setup vir=
tio_net\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Generate a random ethernet address for the other sid=
e
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* This is necessary so we can allow it to give us a =
consistent
> + =A0 =A0 =A0 =A0* MAC address for itself, using something board-spec=
ific
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* The feature bits must match for it to work correct=
ly
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 config =3D (struct virtio_net_config *)vdev->host_statu=
s->config;
> + =A0 =A0 =A0 random_ether_addr(config->mac);
> + =A0 =A0 =A0 dev_info(priv->dev, "Generated MAC %pM\n", config->mac)=
;
> +
> + =A0 =A0 =A0 /* Set the feature bits for the device */
> + =A0 =A0 =A0 set_bit(VIRTIO_NET_F_MAC, =A0 =A0 =A0 &features);
> + =A0 =A0 =A0 set_bit(VIRTIO_NET_F_CSUM, =A0 =A0 =A0&features);
> + =A0 =A0 =A0 set_bit(VIRTIO_NET_F_GSO, =A0 =A0 =A0 &features);
> + =A0 =A0 =A0 set_bit(VIRTIO_NET_F_MRG_RXBUF, &features);
> +
> + =A0 =A0 =A0 vdev->host_status->features[0] =3D cpu_to_le32(features=
);
> + =A0 =A0 =A0 vdev->vdev.id.device =3D VIRTIO_ID_NET;
> +
> + =A0 =A0 =A0 /* Register the virtio device */
> + =A0 =A0 =A0 return register_virtio_device(&vdev->vdev);
> +}
> +
> +/*------------------------------------------------------------------=
----------*/
> +/* Interrupt Handling =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> +/*------------------------------------------------------------------=
----------*/
> +
> +static irqreturn_t vdev_interrupt(int irq, void *dev_id)
> +{
> + =A0 =A0 =A0 struct vop_dev *priv =3D dev_id;
> + =A0 =A0 =A0 struct virtqueue *vq;
> + =A0 =A0 =A0 u32 omisr, odr;
> +
> + =A0 =A0 =A0 omisr =3D ioread32(priv->immr + OMISR_OFFSET);
> + =A0 =A0 =A0 odr =A0 =3D ioread32(priv->immr + ODR_OFFSET);
> +
> + =A0 =A0 =A0 /* Check the status register for doorbell interrupts */
> + =A0 =A0 =A0 if (!(omisr & 0x8))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return IRQ_NONE;
> +
> + =A0 =A0 =A0 /* Clear all doorbell interrupts */
> + =A0 =A0 =A0 iowrite32(odr, priv->immr + ODR_OFFSET);
> +
> + =A0 =A0 =A0 if (odr & 0x4) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq =3D &priv->devices[0].virtqueues[0].=
vq;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->callback(vq);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (odr & 0x8) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq =3D &priv->devices[0].virtqueues[1].=
vq;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vq->callback(vq);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return IRQ_HANDLED;
> +}
> +
> +/*------------------------------------------------------------------=
----------*/
> +/* PCI Subsystem =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
*/
> +/*------------------------------------------------------------------=
----------*/
> +
> +static int vop_probe(struct pci_dev *dev, const struct pci_device_id=
 *id)
> +{
> + =A0 =A0 =A0 struct vop_dev *priv;
> + =A0 =A0 =A0 int ret;
> +
> + =A0 =A0 =A0 priv =3D kzalloc(sizeof(*priv), GFP_KERNEL);
> + =A0 =A0 =A0 if (!priv) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -ENOMEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_return;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 pci_set_drvdata(dev, priv);
> + =A0 =A0 =A0 priv->dev =3D &dev->dev;
> +
> + =A0 =A0 =A0 /* Hardware Initialization */
> + =A0 =A0 =A0 ret =3D pci_enable_device(dev);
> + =A0 =A0 =A0 if (ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_kfree_priv;
> +
> + =A0 =A0 =A0 pci_set_master(dev);
> + =A0 =A0 =A0 ret =3D pci_request_regions(dev, driver_name);
> + =A0 =A0 =A0 if (ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_pci_disable_device;
> +
> + =A0 =A0 =A0 priv->immr =3D pci_ioremap_bar(dev, 0);
> + =A0 =A0 =A0 if (!priv->immr) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -ENOMEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_pci_release_regions;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 priv->netregs =3D pci_ioremap_bar(dev, 1);
> + =A0 =A0 =A0 if (!priv->netregs) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -ENOMEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_iounmap_immr;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* The device can only see the lowest 1GB of memory ove=
r the bus */
> + =A0 =A0 =A0 dev->dev.coherent_dma_mask =3D DMA_BIT_MASK(30);
> + =A0 =A0 =A0 ret =3D dma_set_mask(&dev->dev, DMA_BIT_MASK(30));
> + =A0 =A0 =A0 if (ret) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&dev->dev, "Unable to set DMA m=
ask\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_iounmap_netregs;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Allocate the host memory, for writing by the guest *=
/
> + =A0 =A0 =A0 priv->host_mem =3D dma_alloc_coherent(&dev->dev, VOP_HO=
ST_MEM_SIZE,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &priv->host_mem_addr, G=
=46P_KERNEL);
> + =A0 =A0 =A0 if (!priv->host_mem) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&dev->dev, "Unable to allocate =
host memory\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -ENOMEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_iounmap_netregs;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* We use the guest's mailbox 0 to hold the host memory=
 address */
> + =A0 =A0 =A0 iowrite32(priv->host_mem_addr, priv->immr + IMR0_OFFSET=
);
> +
> + =A0 =A0 =A0 /* Reset all of the devices */
> + =A0 =A0 =A0 iowrite32(0x1, priv->immr + IDR_OFFSET);
> +
> + =A0 =A0 =A0 /* Mask all of the MBOX interrupts */
> + =A0 =A0 =A0 iowrite32(0x1 | 0x2, priv->immr + OMIMR_OFFSET);
> +
> + =A0 =A0 =A0 /* Setup the virtio_net instance */
> + =A0 =A0 =A0 ret =3D register_virtio_net(priv);
> + =A0 =A0 =A0 if (ret) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&dev->dev, "Unable to register =
virtio_net\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_free_host_mem;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Hook up the interrupt handler */
> + =A0 =A0 =A0 ret =3D request_irq(dev->irq, vdev_interrupt, IRQF_SHAR=
ED, driver_name, priv);
> + =A0 =A0 =A0 if (ret) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&dev->dev, "Unable to register =
interrupt handler\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_unregister_virtio_net;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Start virtio_net */
> + =A0 =A0 =A0 iowrite32(0x1, priv->immr + IMR1_OFFSET);
> + =A0 =A0 =A0 iowrite32(0x2, priv->immr + IDR_OFFSET);
> +
> + =A0 =A0 =A0 return 0;
> +
> +out_unregister_virtio_net:
> + =A0 =A0 =A0 unregister_virtio_device(&priv->devices[0].vdev);
> +out_free_host_mem:
> + =A0 =A0 =A0 dma_free_coherent(&dev->dev, VOP_HOST_MEM_SIZE, priv->h=
ost_mem,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->host_mem_addr);
> +out_iounmap_netregs:
> + =A0 =A0 =A0 iounmap(priv->netregs);
> +out_iounmap_immr:
> + =A0 =A0 =A0 iounmap(priv->immr);
> +out_pci_release_regions:
> + =A0 =A0 =A0 pci_release_regions(dev);
> +out_pci_disable_device:
> + =A0 =A0 =A0 pci_disable_device(dev);
> +out_kfree_priv:
> + =A0 =A0 =A0 kfree(priv);
> +out_return:
> + =A0 =A0 =A0 return ret;
> +}
> +
> +static void vop_remove(struct pci_dev *dev)
> +{
> + =A0 =A0 =A0 struct vop_dev *priv =3D pci_get_drvdata(dev);
> +
> + =A0 =A0 =A0 free_irq(dev->irq, priv);
> +
> + =A0 =A0 =A0 /* Reset everything */
> + =A0 =A0 =A0 iowrite32(0x1, priv->immr + IDR_OFFSET);
> +
> + =A0 =A0 =A0 /* Unregister virtio_net */
> + =A0 =A0 =A0 unregister_virtio_device(&priv->devices[0].vdev);
> +
> + =A0 =A0 =A0 /* Clear the host memory address from the guest's mailb=
ox 0 */
> + =A0 =A0 =A0 iowrite32(0x0, priv->immr + IMR0_OFFSET);
> + =A0 =A0 =A0 iowrite32(0x0, priv->immr + IMR1_OFFSET);
> +
> + =A0 =A0 =A0 dma_free_coherent(&dev->dev, VOP_HOST_MEM_SIZE, priv->h=
ost_mem,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->host_mem_addr);
> + =A0 =A0 =A0 iounmap(priv->netregs);
> + =A0 =A0 =A0 iounmap(priv->immr);
> + =A0 =A0 =A0 pci_release_regions(dev);
> + =A0 =A0 =A0 pci_disable_device(dev);
> + =A0 =A0 =A0 kfree(priv);
> +}
> +
> +#define PCI_DEVID_FSL_MPC8349EMDS 0x0080
> +
> +/* The list of devices that this module will support */
> +static struct pci_device_id vop_ids[] =3D {
> + =A0 =A0 =A0 { PCI_DEVICE(PCI_VENDOR_ID_FREESCALE, PCI_DEVID_FSL_MPC=
8349EMDS), },
> + =A0 =A0 =A0 { 0, }
> +};
> +MODULE_DEVICE_TABLE(pci, vop_ids);
> +
> +static struct pci_driver vop_pci_driver =3D {
> + =A0 =A0 =A0 .name =A0 =A0 =3D (char *)driver_name,
> + =A0 =A0 =A0 .id_table =3D vop_ids,
> + =A0 =A0 =A0 .probe =A0 =A0=3D vop_probe,
> + =A0 =A0 =A0 .remove =A0 =3D vop_remove,
> +};
> +
> +/*------------------------------------------------------------------=
----------*/
> +/* Module Init / Exit =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> +/*------------------------------------------------------------------=
----------*/
> +
> +static int __init vop_init(void)
> +{
> + =A0 =A0 =A0 return pci_register_driver(&vop_pci_driver);
> +}
> +
> +static void __exit vop_exit(void)
> +{
> + =A0 =A0 =A0 pci_unregister_driver(&vop_pci_driver);
> +}
> +
> +MODULE_AUTHOR("Ira W. Snyder <iws@ovro.caltech.edu>");
> +MODULE_DESCRIPTION("Virtio-PCI-Host Test Driver");
> +MODULE_LICENSE("GPL");
> +
> +module_init(vop_init);
> +module_exit(vop_exit);
> diff --git a/drivers/virtio/vop_hw.h b/drivers/virtio/vop_hw.h
> new file mode 100644
> index 0000000..8a19d3f
> --- /dev/null
> +++ b/drivers/virtio/vop_hw.h
> @@ -0,0 +1,80 @@
> +/*
> + * Register offsets for the MPC8349EMDS Message Unit from the IMMR b=
ase address
> + *
> + * Copyright (c) 2008 Ira W. Snyder <iws@ovro.caltech.edu>
> + *
> + * This file is licensed under the terms of the GNU General Public L=
icense
> + * version 2. This program is licensed "as is" without any warranty =
of any
> + * kind, whether express or implied.
> + */
> +
> +#ifndef PCINET_HW_H
> +#define PCINET_HW_H
> +
> +#define SGPRL_OFFSET =A0 =A0 =A0 =A0 =A0 0x0100
> +#define SGPRH_OFFSET =A0 =A0 =A0 =A0 =A0 0x0104
> +
> +/* mpc8349emds message unit register offsets */
> +#define OMISR_OFFSET =A0 =A0 =A0 =A0 =A0 0x8030
> +#define OMIMR_OFFSET =A0 =A0 =A0 =A0 =A0 0x8034
> +#define IMR0_OFFSET =A0 =A0 =A0 =A0 =A0 =A00x8050
> +#define IMR1_OFFSET =A0 =A0 =A0 =A0 =A0 =A00x8054
> +#define OMR0_OFFSET =A0 =A0 =A0 =A0 =A0 =A00x8058
> +#define OMR1_OFFSET =A0 =A0 =A0 =A0 =A0 =A00x805C
> +#define ODR_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 0x8060
> +#define IDR_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 0x8068
> +#define IMISR_OFFSET =A0 =A0 =A0 =A0 =A0 0x8080
> +#define IMIMR_OFFSET =A0 =A0 =A0 =A0 =A0 0x8084
> +
> +
> +/* mpc8349emds pci and local access window register offsets */
> +#define LAWAR0_OFFSET =A0 =A0 =A0 =A0 =A00x0064
> +#define LAWAR0_ENABLE =A0 =A0 =A0 =A0 =A0(1<<31)
> +
> +#define POCMR0_OFFSET =A0 =A0 =A0 =A0 =A00x8410
> +#define POCMR0_ENABLE =A0 =A0 =A0 =A0 =A0(1<<31)
> +
> +#define POTAR0_OFFSET =A0 =A0 =A0 =A0 =A00x8400
> +
> +#define LAWAR1_OFFSET =A0 =A0 =A0 =A0 =A00x006c
> +#define LAWAR1_ENABLE =A0 =A0 =A0 =A0 =A0(1<<31)
> +
> +#define POCMR1_OFFSET =A0 =A0 =A0 =A0 =A00x8428
> +#define POCMR1_ENABLE =A0 =A0 =A0 =A0 =A0(1<<31)
> +
> +#define POTAR1_OFFSET =A0 =A0 =A0 =A0 =A00x8418
> +
> +
> +/* mpc8349emds dma controller register offsets */
> +#define DMAMR0_OFFSET =A0 =A0 =A0 =A0 =A00x8100
> +#define DMASR0_OFFSET =A0 =A0 =A0 =A0 =A00x8104
> +#define DMASAR0_OFFSET =A0 =A0 =A0 =A0 0x8110
> +#define DMADAR0_OFFSET =A0 =A0 =A0 =A0 0x8118
> +#define DMABCR0_OFFSET =A0 =A0 =A0 =A0 0x8120
> +
> +#define DMA_CHANNEL_BUSY =A0 =A0 =A0 (1<<2)
> +
> +#define DMA_DIRECT_MODE_SNOOP =A0(1<<20)
> +#define DMA_CHANNEL_MODE_DIRECT =A0 =A0 =A0 =A0(1<<2)
> +#define DMA_CHANNEL_START =A0 =A0 =A0(1<<0)
> +
> +
> +/* mpc8349emds pci and local access window register offsets */
> +#define LAWAR0_OFFSET =A0 =A0 =A0 =A0 =A00x0064
> +#define LAWAR0_ENABLE =A0 =A0 =A0 =A0 =A0(1<<31)
> +
> +#define POCMR0_OFFSET =A0 =A0 =A0 =A0 =A00x8410
> +#define POCMR0_ENABLE =A0 =A0 =A0 =A0 =A0(1<<31)
> +
> +#define POTAR0_OFFSET =A0 =A0 =A0 =A0 =A00x8400
> +
> +
> +/* mpc8349emds pci and inbound window register offsets */
> +#define PITAR0_OFFSET =A0 =A0 =A0 =A0 =A00x8568
> +#define PIWAR0_OFFSET =A0 =A0 =A0 =A0 =A00x8578
> +
> +#define PIWAR0_ENABLED =A0 =A0 =A0 =A0 (1<<31)
> +#define PIWAR0_PREFETCH =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1<<29)
> +#define PIWAR0_IWS_4K =A0 =A0 =A0 =A0 =A00xb
> +
> +#endif /* PCINET_HW_H */
> --
> 1.5.4.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
