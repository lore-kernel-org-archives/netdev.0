From: Oliver Neukum <oliver@neukum.org>
Subject: Re: zd1211rw regression, device does not enumerate
Date: Mon, 3 Sep 2007 13:48:02 +0200
Message-ID: <200709031348.02998.oliver@neukum.org>
References: <200708310958.38132.oliver@neukum.org> <46D8DAB1.3090503@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb-devel@lists.sourceforge.net,
	"John W.Linville" <linville@tuxdriver.com>,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
To: Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out001.kontent.com ([81.88.40.215]:51556 "EHLO
	smtp-out.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754820AbXICLs1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2007 07:48:27 -0400
In-Reply-To: <46D8DAB1.3090503@gentoo.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Samstag 01 September 2007 schrieb Daniel Drake:
> Oliver Neukum wrote:
> > after bisection it boils down to this patch:
> >=20
> > oliver@oenone:/home/olli2/Trees/linux-2.6> git bisect bad
> > 74553aedd46b3a2cae986f909cf2a3f99369decc is first bad commit
> > commit 74553aedd46b3a2cae986f909cf2a3f99369decc
> > Author: Daniel Drake <dsd@gentoo.org>
> > Date: =A0 Sun Jul 1 18:22:32 2007 +0100
> >=20
> > =A0 =A0 [PATCH] zd1211rw: Defer firmware load until first ifup
> >=20
> > that plugging in my device I get an error:
> > Aug 16 13:17:11 oenone kernel: zd1211rw 3-4.3:1.0: zd1211b chip 0ac=
e:1215 v4810 high 00-02-72 AL2230_RF pa0 g--NS
> > Aug 16 13:17:12 oenone ifup: Cannot enable interface eth2.
>=20
> Can you enable CONFIG_ZD1211RW_DEBUG and post new logs?

No problem:

Sep  3 13:39:48 oenone kernel: hub 3-4:1.0: state 7 ports 7 chg 0000 ev=
t 0008
Sep  3 13:39:48 oenone kernel: hub 3-4:1.0: port 3, status 0101, change=
 0001, 12 Mb/s
Sep  3 13:39:48 oenone kernel: hub 3-4:1.0: debounce: port 3: total 100=
ms stable 100ms status 0x101
Sep  3 13:39:48 oenone kernel: usb 3-4.3: new high speed USB device usi=
ng ehci_hcd and address 8
Sep  3 13:39:48 oenone kernel: usb 3-4.3: default language 0x0409
Sep  3 13:39:48 oenone kernel: usb 3-4.3: new device strings: Mfr=3D16,=
 Product=3D32, SerialNumber=3D0
Sep  3 13:39:48 oenone kernel: usb 3-4.3: Product: USB2.0 WLAN
Sep  3 13:39:48 oenone kernel: usb 3-4.3: Manufacturer: ZyDAS
Sep  3 13:39:48 oenone kernel: usb 3-4.3: uevent
Sep  3 13:39:48 oenone kernel: usb 3-4.3: usb_probe_device
Sep  3 13:39:48 oenone kernel: usb 3-4.3: configuration #1 chosen from =
1 choice
Sep  3 13:39:48 oenone kernel: usb 3-4.3: adding 3-4.3:1.0 (config #1, =
interface 0)
Sep  3 13:39:48 oenone kernel: usb 3-4.3:1.0: uevent
Sep  3 13:39:48 oenone kernel: usb 3-4.3:1.0: uevent
Sep  3 13:39:48 oenone kernel: drivers/usb/core/inode.c: creating file =
'008'
Sep  3 13:39:48 oenone kernel: hub 3-4:1.0: state 7 ports 7 chg 0000 ev=
t 0008
Sep  3 13:39:49 oenone kernel: ieee80211_crypt: registered algorithm 'N=
ULL'
Sep  3 13:39:49 oenone kernel: ieee80211: 802.11 data/management/contro=
l stack, git-1.1.13
Sep  3 13:39:49 oenone kernel: ieee80211: Copyright (C) 2004-2005 Intel=
 Corporation <jketreno@linux.intel.com>
Sep  3 13:39:49 oenone kernel: zd1211rw usb_init()
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: usb_probe_interface
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: usb_probe_interface =
- got id
Sep  3 13:39:49 oenone kernel: usb 3-4.3: print_id() 0ace:1215 v4810 hi=
gh
Sep  3 13:39:49 oenone kernel: usb 3-4.3: reset high speed USB device u=
sing ehci_hcd and address 8
Sep  3 13:39:49 oenone kernel: usb_endpoint usbdev3.8_ep01: ep_device_r=
elease called for usbdev3.8_ep01
Sep  3 13:39:49 oenone kernel: usb_endpoint usbdev3.8_ep82: ep_device_r=
elease called for usbdev3.8_ep82
Sep  3 13:39:49 oenone kernel: usb_endpoint usbdev3.8_ep83: ep_device_r=
elease called for usbdev3.8_ep83
Sep  3 13:39:49 oenone kernel: usb_endpoint usbdev3.8_ep04: ep_device_r=
elease called for usbdev3.8_ep04
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: zd_netdev_alloc() ne=
tdev->flags 0x1002
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: zd_netdev_alloc() ne=
tdev->features 0x00000000
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: zd_chip_read_mac_add=
r_fw()=20
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: probe() successful
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: eth1
Sep  3 13:39:49 oenone kernel: usbcore: registered new interface driver=
 zd1211rw
Sep  3 13:39:49 oenone kernel: zd1211rw initialized
Sep  3 13:39:49 oenone ifup:     eth1     =20
Sep  3 13:39:49 oenone ifup-wireless:     eth1      warning: using NO e=
ncryption
Sep  3 13:39:49 oenone ifup-wireless: command 'iwconfig eth1 nick oenon=
e' returned
Sep  3 13:39:49 oenone ifup-wireless:  Error for wireless request "Set =
Nickname" (8B1C) :
Sep  3 13:39:49 oenone ifup-wireless:     SET failed on device eth1 ; O=
peration not supported.
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: set_security()=20
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: set_security()    .l=
evel =3D 0
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: set_security()    .e=
nabled =3D 0
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: set_security()    .e=
ncrypt =3D 0
Sep  3 13:39:49 oenone kernel: SoftMAC: Associate: Scanning for network=
s first.
Sep  3 13:39:49 oenone kernel: SoftMAC: Associate: failed to initiate s=
can. Is device up?
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: zd_usb_init_hw()=20
Sep  3 13:39:49 oenone kernel: usb 3-4.3: request_fw_file() fw name zd1=
211/zd1211b_ub
Sep  3 13:39:49 oenone kernel: usb 3-4.3: upload_firmware() firmware de=
vice id 0x4810 is equal to the actual device id
Sep  3 13:39:49 oenone kernel: usb 3-4.3: request_fw_file() fw name zd1=
211/zd1211b_uphr
Sep  3 13:39:49 oenone kernel: usb 3-4.3: upload_code() transfer size 4=
096
Sep  3 13:39:49 oenone kernel: usb 3-4.3: upload_code() transfer size 1=
024
Sep  3 13:39:49 oenone kernel: usb 3-4.3: upload_code() firmware confir=
m return value 0x01
Sep  3 13:39:49 oenone kernel: usb_endpoint usbdev3.8_ep01: ep_device_r=
elease called for usbdev3.8_ep01
Sep  3 13:39:49 oenone kernel: usb_endpoint usbdev3.8_ep82: ep_device_r=
elease called for usbdev3.8_ep82
Sep  3 13:39:49 oenone kernel: usb_endpoint usbdev3.8_ep83: ep_device_r=
elease called for usbdev3.8_ep83
Sep  3 13:39:49 oenone kernel: usb_endpoint usbdev3.8_ep04: ep_device_r=
elease called for usbdev3.8_ep04
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: zd_usb_enable_int()=20
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: zd_usb_enable_int() =
submit urb ffff810086bea880
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh1-0001/ffff81000069e78=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: zd_chip_init_hw()=20
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: dump_cr() CR_AFTER_P=
NP 0x00000000
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: dump_cr() CR_GPI_EN =
0x00000000
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: dump_cr() CR_INTERRU=
PT 0x00000000
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: read_fw_regs_offset(=
) fw_regs_base: 0xf7f1
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: read_pod() E2P_POD 0=
x80000584
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: read_pod() RF AL2230=
_RF 0x4 PA type 0x0 patch CCK 1 patch CR157 0 patch 6M 0 new PHY 1 link=
 LED2 tx led 1
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: hw_init()=20
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: zd1211b_hw_reset_phy=
()=20
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: zd_chip_lock_phy_reg=
s() CR_REG1: 0x00 -> 0x00
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: zd_chip_unlock_phy_r=
egs() CR_REG1: 0x00 -> 0x80
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: zd1211b_hw_init_hmac=
()=20
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: get_aw_pt_bi() aw 0 =
pt 0 bi 0
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: set_aw_pt_bi() aw 0 =
pt 99 bi 100
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: zd_chip_lock_phy_reg=
s() CR_REG1: 0xa0 -> 0x20
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: zd_usb_rfwrite() val=
ue 0x0241000 bits 24
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: zd_chip_unlock_phy_r=
egs() CR_REG1: 0x20 -> 0xa0
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: firmware version 472=
5
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: dump_fw_registers() =
=46W_FIRMWARE_VER 0x4725
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: dump_fw_registers() =
=46W_USB_SPEED 0x0001
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: dump_fw_registers() =
=46W_FIX_TX_RATE 0x0000
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: dump_fw_registers() =
=46W_LINK_STATUS 0x0000
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: dump_cr() CR_AFTER_P=
NP 0x00000001
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: dump_cr() CR_GPI_EN =
0x00000000
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: dump_cr() CR_INTERRU=
PT 0x00000000
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: zd1211b chip 0ace:12=
15 v4810 high 00-02-72 AL2230_RF pa0 g--NS
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: zd_read_regdomain() =
regdomain: 0x30
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: regdomain 0x30
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh1-0001/ffff81000069e=
780 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: zd_usb_disable_int()=
 urb ffff810086bea880 killed
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: zd_usb_enable_int()=20
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: zd_usb_enable_int() =
submit urb ffff810086bea880
Sep  3 13:39:49 oenone kernel: ehci_hcd 0000:00:02.2: reused qh ffff810=
00069e780 schedule
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh1-0001/ffff81000069e78=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: zd_write_mac_addr() =
mac addr 00:02:72:5d:a5:16
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: zd1211rw 3-4.3:1.0: zd_chip_set_basic_ra=
tes_locked() ff0f
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:51 oenone kernel: zd1211rw 3-4.3:1.0: zd_usb_ioread16v() r=
ead timed out
Sep  3 13:39:51 oenone kernel: zd1211rw 3-4.3:1.0: zd_ioread32v_locked(=
) error: zd_ioread16v_locked. Error number -110
Sep  3 13:39:51 oenone kernel: zd1211rw 3-4.3:1.0: error ioread32(CR_RE=
G1): -110
Sep  3 13:39:51 oenone kernel: usb 3-4.3: unlink qh1-0001/ffff81000069e=
780 start 0 [2/0 us]
Sep  3 13:39:51 oenone kernel: zd1211rw 3-4.3:1.0: zd_usb_disable_int()=
 urb ffff810086bea880 killed
Sep  3 13:39:51 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:39:51 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 0
Sep  3 13:39:51 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:39:51 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 0
Sep  3 13:39:51 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:39:51 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 0
Sep  3 13:39:52 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:39:52 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 0
Sep  3 13:39:53 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:39:53 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 0
Sep  3 13:39:54 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:39:54 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 0
Sep  3 13:39:55 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:39:55 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 0
Sep  3 13:39:56 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:39:56 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 0
Sep  3 13:39:56 oenone ifup-dhcp: Starting DHCP Client Daemon on eth1..=
=2E=20
Sep  3 13:39:56 oenone ifup-dhcp: .=20
Sep  3 13:39:56 oenone kernel: NET: Registered protocol family 17
Sep  3 13:39:56 oenone kernel: zd1211rw 3-4.3:1.0: zd_usb_enable_int()=20
Sep  3 13:39:56 oenone kernel: zd1211rw 3-4.3:1.0: zd_usb_enable_int() =
submit urb ffff81009246c0c0
Sep  3 13:39:56 oenone kernel: ehci_hcd 0000:00:02.2: reused qh ffff810=
00069e780 schedule
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh1-0001/ffff81000069e78=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: zd1211rw 3-4.3:1.0: zd_write_mac_addr() =
mac addr 00:02:72:5d:a5:16
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: zd1211rw 3-4.3:1.0: zd_chip_set_basic_ra=
tes_locked() ff0f
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: zd1211rw 3-4.3:1.0: zd_chip_lock_phy_reg=
s() CR_REG1: 0xa0 -> 0x20
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: zd1211rw 3-4.3:1.0: zd_chip_unlock_phy_r=
egs() CR_REG1: 0x20 -> 0xa0
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: zd1211rw 3-4.3:1.0: zd_chip_lock_phy_reg=
s() CR_REG1: 0xa0 -> 0x20
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: zd1211rw 3-4.3:1.0: zd_rf_set_channel() =
channel: 1
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: zd1211rw 3-4.3:1.0: update_pwr_int() cha=
nnel 1 pwr_int 0x60
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: zd1211rw 3-4.3:1.0: update_ofdm_cal() ch=
annel 1 ofdm_cal 36M 0x7c 48M 0x70 54M 0x63
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: zd1211rw 3-4.3:1.0: update_pwr_cal() cha=
nnel 1 pwr_cal 0x94
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: zd1211rw 3-4.3:1.0: patch_cck_gain() pat=
ching value 1c
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: zd1211rw 3-4.3:1.0: zd_chip_unlock_phy_r=
egs() CR_REG1: 0x20 -> 0xa0
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: zd1211rw 3-4.3:1.0: zd_usb_enable_rx()=20
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: zd1211rw 3-4.3:1.0: housekeeping_enable(=
)=20
Sep  3 13:39:56 oenone kernel: zd1211rw 3-4.3:1.0: bssinfo_change() cha=
nges: 7
Sep  3 13:39:56 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_set_multicast=
_list() mc addr 01:00:5e:00:00:01
Sep  3 13:39:56 oenone syslog-ng[2393]: last message repeated 2 times
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: zd1211rw 3-4.3:1.0: zd_chip_set_rts_cts_=
rate_locked() rts_rate=3D0 preamble=3D0
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: zd1211rw 3-4.3:1.0: zd_chip_set_basic_ra=
tes_locked() ff0f
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: zd1211rw 3-4.3:1.0: zd_chip_set_multicas=
t_hash() hash l 0x00000001 h 0x80000000
Sep  3 13:39:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:57 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:39:57 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:39:57 oenone ifup-dhcp: .=20
Sep  3 13:39:57 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:57 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:57 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:57 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:58 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:39:58 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:39:58 oenone ifup-dhcp: .=20
Sep  3 13:39:58 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:58 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:58 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:58 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:39:59 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:39:59 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:39:59 oenone ifup-dhcp: .=20
Sep  3 13:39:59 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:39:59 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:00 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:00 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:00 oenone ifup-dhcp: .=20
Sep  3 13:40:00 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:00 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:00 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:00 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:01 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:01 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:01 oenone ifup-dhcp: no IP address yet... backgrounding.=20
Sep  3 13:40:01 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:01 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:01 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:01 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:02 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:02 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:02 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:02 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:03 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:03 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:03 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:03 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:03 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:03 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:04 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:04 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:04 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:04 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:04 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:04 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:05 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:05 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:05 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:05 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:06 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:06 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:06 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:06 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:06 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:06 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:07 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:07 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:07 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:07 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:07 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:07 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:08 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:08 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:08 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:08 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:09 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:09 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:09 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:09 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:09 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:09 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:10 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:10 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:10 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:10 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:10 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:10 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:11 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:11 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:11 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:11 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:12 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:12 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:12 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:12 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:12 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:12 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:13 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:13 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:13 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:13 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:13 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:13 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:14 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:14 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:14 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:14 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:15 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:15 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:15 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:15 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:15 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:15 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:16 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:16 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:16 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:16 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:16 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:16 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:17 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:17 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:17 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:17 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:18 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:18 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:18 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:18 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:18 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:18 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:19 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:19 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:19 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:19 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:19 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:19 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:20 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:20 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:20 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:20 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:21 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:21 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:21 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:21 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:21 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:21 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:22 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:22 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:22 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:22 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:22 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:22 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:23 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:23 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:23 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:23 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:24 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:24 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:24 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:24 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:24 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:24 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:25 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:25 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:25 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:25 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:25 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:25 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:26 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:26 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:26 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:26 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:27 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:27 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:27 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:27 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:27 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:27 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:28 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:28 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:28 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:28 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:28 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:28 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:29 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:29 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:29 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:29 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:30 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:30 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:30 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:30 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:30 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:30 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:31 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:31 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:31 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:31 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:31 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:31 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:32 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:32 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:32 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:32 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:33 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:33 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:33 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:33 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:33 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:33 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:34 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:34 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:34 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:34 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:34 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:34 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:35 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:35 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:35 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:35 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:36 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:36 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:36 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:36 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:36 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:36 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:37 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:37 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:37 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:37 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:37 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:37 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:38 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:38 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:38 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:38 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:39 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:39 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:39 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:39 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:39 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:39 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:40 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:40 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:40 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:40 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:40 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:40 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:41 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:41 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:41 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:41 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:42 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:42 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:42 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:42 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:42 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:42 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:43 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:43 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:43 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:43 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:43 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:43 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:44 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:44 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:44 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:44 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:45 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:45 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:45 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:45 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:45 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:45 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:46 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:46 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:46 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:46 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:46 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:46 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:47 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:47 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:47 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:47 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:48 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:48 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:48 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:48 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:48 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:48 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:49 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:49 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:50 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:50 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:50 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:50 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:51 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:51 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:51 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:51 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:51 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:51 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:52 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:52 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:52 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:52 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:52 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:52 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:53 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:53 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:53 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:53 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:54 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:54 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:54 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:54 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:54 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:54 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:55 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:55 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:55 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:55 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:55 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:55 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:56 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:56 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:57 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:57 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:57 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:57 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:57 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:57 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:58 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:58 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:58 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:58 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:58 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:58 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:40:59 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:40:59 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:40:59 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:40:59 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:00 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:00 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:00 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:00 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:00 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:00 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:01 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:01 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:01 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:01 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:01 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:01 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:02 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:02 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:02 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:02 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:03 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:03 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:03 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:03 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:03 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:03 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:04 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:04 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:04 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:04 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:04 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:04 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:05 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:05 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:05 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:05 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:06 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:06 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:06 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:06 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:06 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:06 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:07 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:07 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:07 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:07 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:07 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:07 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:08 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:08 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:08 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:08 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:09 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:09 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:09 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:09 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:09 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:09 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:10 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:10 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:10 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:10 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:10 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:10 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:11 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:11 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:11 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:11 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:12 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:12 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:12 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:12 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:12 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:12 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:13 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:13 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:13 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:13 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:13 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:13 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:14 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:14 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:14 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:14 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:15 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:15 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:15 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:15 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:15 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:15 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:16 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:16 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:16 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:16 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:16 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:16 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:17 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:17 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:17 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:17 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:18 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:18 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:18 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:18 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:18 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:18 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:19 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:19 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:19 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:19 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:19 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:19 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:20 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:20 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:20 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:20 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:21 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:21 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:21 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:21 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:21 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:21 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:22 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:22 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:22 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:22 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:22 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:22 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:23 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:23 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:23 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:23 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:24 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:24 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:24 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:24 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:24 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:24 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:25 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:25 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:25 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:25 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:25 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:25 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:26 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:26 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:26 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:26 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:27 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:27 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:27 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:27 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:27 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:27 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:28 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:28 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:28 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:28 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:28 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:28 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:29 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:29 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:29 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:29 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:30 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:30 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:30 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:30 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:30 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:30 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:31 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:31 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:31 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:31 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:31 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:31 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:32 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:32 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:32 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:32 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:33 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:33 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:33 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:33 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:33 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:33 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:34 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:34 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:34 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:34 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:34 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:34 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:35 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:35 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:35 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:35 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:36 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:36 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:36 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:36 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:36 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:36 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:37 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:37 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:37 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:37 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:37 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:37 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:38 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:38 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:38 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:38 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:39 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:39 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:39 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:39 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:39 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:39 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:40 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:40 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:40 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:40 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:40 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:40 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:41 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:41 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:41 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:41 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:42 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:42 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:42 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:42 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:42 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:42 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:43 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:43 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:43 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:43 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:43 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:43 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:44 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:44 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:44 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:44 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:45 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:45 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:45 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:45 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:45 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:45 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:46 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:46 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:46 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:46 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:46 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:46 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:47 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:47 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:47 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:47 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:48 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:48 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:48 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:48 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:48 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:48 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:49 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:49 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:49 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:49 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:50 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:50 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:50 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:50 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:51 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:51 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:51 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:51 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:51 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:51 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:52 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:52 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:52 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:52 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:52 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:52 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:53 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:53 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:53 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:53 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:54 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:54 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:54 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:54 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:54 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:54 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:55 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:55 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:55 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:55 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:55 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:55 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:56 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:56 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:56 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:56 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:57 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:57 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:57 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:57 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:57 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:57 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:58 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:58 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:58 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:58 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:58 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:58 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:41:59 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:41:59 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:41:59 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:41:59 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:00 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:42:00 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:42:00 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:00 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:00 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:00 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:01 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:42:01 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:42:01 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:01 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:01 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:01 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:02 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:42:02 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:42:02 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:02 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:03 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:42:03 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:42:03 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:03 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:03 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:03 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:04 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:42:04 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:42:04 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:04 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:04 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:04 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:05 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:42:05 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:42:05 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:05 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:06 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:42:06 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:42:06 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:06 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:06 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:06 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:07 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:42:07 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:42:07 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:07 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:07 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:07 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:08 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:42:08 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:42:08 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:08 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:09 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:42:09 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:42:09 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:09 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:09 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:09 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:10 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:42:10 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:42:10 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:10 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:10 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:10 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:11 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:42:11 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:42:11 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:11 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:12 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:42:12 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:42:12 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:12 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:12 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:12 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:13 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:42:13 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:42:13 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:13 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:13 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:13 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:14 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:42:14 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:42:14 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:14 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:15 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:42:15 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:42:15 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:15 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:15 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:15 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:16 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:42:16 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:42:16 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:16 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:16 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:16 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:17 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:42:17 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:42:17 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:17 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:18 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:42:18 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:42:18 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:18 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:18 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:18 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:19 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:42:19 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:42:19 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:19 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:19 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:19 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:20 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:42:20 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:42:20 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:20 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:21 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:42:21 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:42:21 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:21 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:21 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:21 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:22 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:42:22 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:42:22 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:22 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:22 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:22 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:23 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:42:23 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:42:23 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:23 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:24 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:42:24 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:42:24 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:24 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:24 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:24 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:25 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:42:25 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:42:25 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:25 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:25 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:25 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:26 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:42:26 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:42:26 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:26 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:27 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:42:27 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:42:27 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:27 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:27 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:27 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:28 oenone kernel: zd1211rw 3-4.3:1.0: iw_get_range()=20
Sep  3 13:42:28 oenone kernel: zd1211rw 3-4.3:1.0: zd_mac_get_channel()=
 channel 1
Sep  3 13:42:28 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:28 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]
Sep  3 13:42:28 oenone kernel: usb 3-4.3: link qh0-00ff/ffff81000069e82=
0 start 0 [2/0 us]
Sep  3 13:42:28 oenone kernel: usb 3-4.3: unlink qh0-00ff/ffff81000069e=
820 start 0 [2/0 us]

