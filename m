From: Grant Grundler <grundler@chromium.org>
Subject: Re: drivers/net/usb/asix: strange numeration of eth interfaces
Date: Mon, 19 Dec 2011 10:37:13 -0800
Message-ID: <CANEJEGseZ6Emt=iT1wGyQVJdAEsjgDX6yOV4OGa6Aht=BAVT+A@mail.gmail.com>
References: <1324280623.19383.8.camel@igor-pc.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Allan Chou <allan@asix.com.tw>,
	Freddy Xin <freddy@asix.com.tw>,
	Mark Lord <kernel@teksavvy.com>, netdev@vger.kernel.org
To: Igor Egorkin <igor@egorkin.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1324280623.19383.8.camel@igor-pc.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

+Freddy Xin, Mark Lord, +netdev

On Sun, Dec 18, 2011 at 11:43 PM, Igor Egorkin <igor@egorkin.ru> wrote:
> Hello!
>
> $ uname -a
> Linux 2.6.32-5-amd64 #1 SMP Thu Nov 3 03:41:26 UTC 2011 x86_64 GNU/Li=
nux
>
> $ cat /etc/debian_version
> 6.0.3
>
> $ lsusb|grep -i asix
> Bus 004 Device 014: ID 0b95:772b ASIX Electronics Corp.
>
>
> 1) Driver asix.c from linux-3.2-rc6.
> =C2=A0 asix.c little modified for compiling in 2.6.32 . Diff is at th=
e end of message.

Hi Igor!
The goal(s) of your email/patch aren't 100% clear to me.

Is the main goal to provide a backport of 3.2-rc6  asix.c driver to
pre-2.6.35 kernels?

(If so - thanks! I'm sure someone can make use of it.)

Why the comparison to ASIX v4.2.0 driver?

cheers,
grant

> =C2=A0Adapter inserted to USB connector:
> Dec 18 20:03:24 kernel: [492657.344037] usb 4-2: new high speed USB d=
evice using ehci_hcd and address 12
> Dec 18 20:03:24 kernel: [492657.489541] usb 4-2: New USB device found=
, idVendor=3D0b95, idProduct=3D772b
> Dec 18 20:03:24 kernel: [492657.489545] usb 4-2: New USB device strin=
gs: Mfr=3D1, Product=3D2, SerialNumber=3D3
> Dec 18 20:03:24 kernel: [492657.489548] usb 4-2: Product: AX88772B
> Dec 18 20:03:24 kernel: [492657.489550] usb 4-2: Manufacturer: ASIX E=
lec. Corp.
> Dec 18 20:03:24 kernel: [492657.489552] usb 4-2: SerialNumber: 000001
> Dec 18 20:03:24 kernel: [492657.489661] usb 4-2: configuration #1 cho=
sen from 1 choice
> Dec 18 20:03:24 kernel: [492657.802645] eth1: register 'asix' at usb-=
0000:01:00.2-2, ASIX AX88772 USB 2.0 Ethernet, 00:60:6e:01:0e:99
>
> # ethtool -i eth1
> Cannot get driver information: No such device
>
> # ethtool -i eth2
> driver: asix
> version: 08-Nov-2011
> firmware-version: ASIX AX88772 USB 2.0 Ethernet
> bus-info: usb-0000:01:00.2-2
>
> $ ip addr ls dev eth1
> Device "eth1" does not exist.
>
> $ ip addr ls dev eth2
> 77: eth2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1=
000
> =C2=A0 =C2=A0link/ether 00:60:6e:01:0e:99 brd ff:ff:ff:ff:ff:ff
>
> =C2=A0Adapter removed from USB connector:
> Dec 18 20:40:58 kernel: [494911.485333] usb 4-2: USB disconnect, addr=
ess 12
> Dec 18 20:40:58 kernel: [494911.485426] eth2: unregister 'asix' usb-0=
000:01:00.2-2, ASIX AX88772 USB 2.0 Ethernet
>
>
>
> 2) Driver AX88772B_772A_760_772_178_LINUX_Driver_v4.2.0_Source.zip fr=
om asix.com.tw . Unmodified.
> Problem is the same.
>
> =C2=A0Adapter inserted to USB connector:
> Dec 18 20:42:53 kernel: [495026.620036] usb 4-2: new high speed USB d=
evice using ehci_hcd and address 13
> Dec 18 20:42:53 kernel: [495026.765514] usb 4-2: New USB device found=
, idVendor=3D0b95, idProduct=3D772b
> Dec 18 20:42:53 kernel: [495026.765519] usb 4-2: New USB device strin=
gs: Mfr=3D1, Product=3D2, SerialNumber=3D3
> Dec 18 20:42:53 kernel: [495026.765522] usb 4-2: Product: AX88772B
> Dec 18 20:42:53 kernel: [495026.765523] usb 4-2: Manufacturer: ASIX E=
lec. Corp.
> Dec 18 20:42:53 kernel: [495026.765525] usb 4-2: SerialNumber: 000001
> Dec 18 20:42:53 kernel: [495026.765639] usb 4-2: configuration #1 cho=
sen from 1 choice
> Dec 18 20:42:54 kernel: [495027.399871] ASIX USB Ethernet Adapter:v4.=
2.0 20:17:18 Dec 17 2011
> Dec 18 20:42:54 kernel: [495027.399873] <6> =C2=A0 =C2=A0http://www.a=
six.com.tw
> Dec 18 20:42:54 kernel: [495027.399877] eth%d: status ep1in, 8 bytes =
period 11
> Dec 18 20:42:54 kernel: [495027.400873] eth1: register 'asix' at usb-=
0000:01:00.2-2, ASIX AX88772B USB 2.0 Ethernet, 00:60:6e:01:0e:99
>
> $ ip addr ls dev eth1
> Device "eth1" does not exist.
>
> $ ip addr ls dev eth2
> 78: eth2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1=
000
> =C2=A0 =C2=A0link/ether 00:60:6e:01:0e:99 brd ff:ff:ff:ff:ff:ff
>
>
> # ethtool -i eth1
> Cannot get driver information: No such device
>
> # ethtool -i eth2
> driver: asix
> version: 22-Aug-2005
> firmware-version: ASIX AX88772B USB 2.0 Ethernet
> bus-info: usb-0000:01:00.2-2
>
> =C2=A0Adapter removed from USB connector:
> Dec 18 20:44:41 kernel: [495134.784792] usb 4-2: USB disconnect, addr=
ess 13
> Dec 18 20:44:41 kernel: [495134.784882] eth2: unregister 'asix' usb-0=
000:01:00.2-2, ASIX AX88772B USB 2.0 Ethernet
>
>
>
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>
>
> =C2=A0For compiling asix.c in 2.6.32 =C2=A0i do modification (i take =
it from AX88772B_772A_760_772_178_LINUX_Driver_v4.2.0_Source.zip):
>
>
> $ diff -ruN asix.c.from_linux-3.2-rc6 asix.c
> --- asix.c.from_linux-3.2-rc6 =C2=A0 2011-12-17 06:36:26.000000000 +0=
400
> +++ asix.c =C2=A0 =C2=A0 =C2=A02011-12-18 20:00:46.000000000 +0400
> @@ -22,7 +22,7 @@
>
> =C2=A0// #define =C2=A0 =C2=A0 DEBUG =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 // error path messages, extra info
> =C2=A0// #define =C2=A0 =C2=A0 VERBOSE =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 // more; success messages
> -
> +#include <linux/version.h>
> =C2=A0#include <linux/module.h>
> =C2=A0#include <linux/kmod.h>
> =C2=A0#include <linux/init.h>
> @@ -593,8 +593,24 @@
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * for our 8 b=
yte filter buffer
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * to avoid al=
locating memory that
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * is tricky t=
o free later */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct netdev_hw_a=
ddr *ha;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 crc_bits;
> +#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,35)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct dev_mc_list=
 *mc_list =3D net->mc_list;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int i;
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memset(data->multi=
_filter, 0, AX_MCAST_FILTER_SIZE);
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Build the multi=
cast hash filter. */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i < =
net->mc_count; i++) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 crc_bits =3D
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 ether_crc(ETH_ALEN,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mc_list->dmi_addr) >> 26;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 data->multi_filter[crc_bits >> 3] |=3D
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 1 << (crc_bits & 7);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 mc_list =3D mc_list->next;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> +#else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct netdev_hw_a=
ddr *ha;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0memset(data->m=
ulti_filter, 0, AX_MCAST_FILTER_SIZE);
>
> @@ -604,7 +620,7 @@
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0data->multi_filter[crc_bits >> 3] |=3D
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A01 << (crc_bits & 7);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> -
> +#endif
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0asix_write_cmd=
_async(dev, AX_CMD_WRITE_MULTI_FILTER, 0, 0,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 AX_MCAST_FILTER_SIZE,=
 data->multi_filter);
>
> @@ -827,18 +843,33 @@
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * for our 8 b=
yte filter buffer
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * to avoid al=
locating memory that
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * is tricky t=
o free later */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct netdev_hw_a=
ddr *ha;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 crc_bits;
> +#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,35)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct dev_mc_list=
 *mc_list =3D net->mc_list;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int i;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0memset(data->m=
ulti_filter, 0, AX_MCAST_FILTER_SIZE);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Build the m=
ulticast hash filter. */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i < =
net->mc_count; i++) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 crc_bits =3D
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 ether_crc(ETH_ALEN,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mc_list->dmi_addr) >> 26;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 data->multi_filter[crc_bits >> 3] |=3D
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 1 << (crc_bits & 7);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 mc_list =3D mc_list->next;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> +#else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct netdev_hw_a=
ddr *ha;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memset(data->multi=
_filter, 0, AX_MCAST_FILTER_SIZE);
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Build the multi=
cast hash filter. */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0netdev_for_eac=
h_mc_addr(ha, net) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0crc_bits =3D ether_crc(ETH_ALEN, ha->addr) >> 26;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0data->multi_filter[crc_bits >> 3] |=3D
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A01 << (crc_bits & 7);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> -
> +#endif
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0asix_write_cmd=
_async(dev, AX_CMD_WRITE_MULTI_FILTER, 0, 0,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 AX_MCAST_FILTER_SIZE,=
 data->multi_filter);
>
>
>
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>
>
> Thank you!
> --
> Igor E.
>
>
