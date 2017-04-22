From: Paul Menzel <paulepanter@users.sourceforge.net>
Subject: r8169: Long link becomes ready times
Date: Sat, 22 Apr 2017 11:05:08 +0200
Message-ID: <1492851908.2760.222.camel@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
        boundary="=-NbzV+UO9bXTEuE9wCps4"
Cc: netdev@vger.kernel.org
To: Realtek linux nic maintainers <nic_swsd@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gw90.de ([188.40.100.199]:47970 "EHLO mail.gw90.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751956AbdDVJlB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 22 Apr 2017 05:41:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-NbzV+UO9bXTEuE9wCps4
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Dear Linux folks,


The ASRock E350M1 has a Realtek ethernet controller.

It takes almost three seconds for the link to become ready. This is
noticeable after resume from suspend, where the user wants to continue
working but first has to wait for the network.

This test is done with Linux 4.10.

```
$ sudo lspci -s 3:00.0 -nn -v
03:00.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd. RTL8111=
/8168/8411 PCI Express Gigabit Ethernet Controller [10ec:8168] (rev 06)
	Subsystem: ASRock Incorporation Motherboard (one of many) [1849:8168]
	Flags: bus master, fast devsel, latency 0, IRQ 26
	I/O ports at 1000 [size=3D256]
	Memory at f0004000 (64-bit, prefetchable) [size=3D4K]
	Memory at f0000000 (64-bit, prefetchable) [size=3D16K]
	Capabilities: [40] Power Management version 3
	Capabilities: [50] MSI: Enable+ Count=3D1/1 Maskable- 64bit+
	Capabilities: [70] Express Endpoint, MSI 01
	Capabilities: [b0] MSI-X: Enable- Count=3D4 Masked-
	Capabilities: [d0] Vital Product Data
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [140] Virtual Channel
	Capabilities: [160] Device Serial Number 01-00-00-00-68-4c-e0-00
	Kernel driver in use: r8169
	Kernel modules: r8169
```

The test below is done, removing the module, and then inserting it.

```
Apr 22 10:56:11.919311 myasrocke350m1 kernel: r8169 0000:03:00.0 eth0: RTL8=
168e/8111e at 0xf82ad000, bc:5f:f4:c8:d3:98, XID 0c200000 IRQ 26
Apr 22 10:56:11.920631 myasrocke350m1 kernel: r8169 0000:03:00.0 eth0: jumb=
o features [frames: 9200 bytes, tx checksumming: ko]
Apr 22 10:56:11.967396 myasrocke350m1 kernel: r8169 0000:03:00.0 eth6: rena=
med from eth0
Apr 22 10:56:12.064323 myasrocke350m1 kernel: IPv6: ADDRCONF(NETDEV_UP): et=
h6: link is not ready
Apr 22 10:56:12.179106 myasrocke350m1 kernel: r8169 0000:03:00.0: firmware:=
 direct-loading firmware rtl_nic/rtl8168e-2.fw
Apr 22 10:56:12.247858 myasrocke350m1 kernel: r8169 0000:03:00.0 eth6: link=
 down
Apr 22 10:56:12.248593 myasrocke350m1 kernel: IPv6: ADDRCONF(NETDEV_UP): et=
h6: link is not ready
Apr 22 10:56:14.992108 myasrocke350m1 kernel: r8169 0000:03:00.0 eth6: link=
 up
Apr 22 10:56:14.993299 myasrocke350m1 kernel: IPv6: ADDRCONF(NETDEV_CHANGE)=
: eth6: link becomes ready
```

Is it possible to get this well below one second?


Thanks,

Paul
--=-NbzV+UO9bXTEuE9wCps4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iF0EABECAB0WIQQ8+w9d414FAVARIpk9fVorbA4dWAUCWPscxQAKCRA9fVorbA4d
WIG6AJ9l9dRk6B6ruk1C3aoz0G+BI6e/owCfZr7VtUlU2k/I7ToPMoiQAFZ89v4=
=s0z+
-----END PGP SIGNATURE-----

--=-NbzV+UO9bXTEuE9wCps4--
