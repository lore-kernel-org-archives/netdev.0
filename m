From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: e100 fail in 2.6.29-rc6-git7, kernel requesting firmware
Date: Sun, 8 Mar 2009 00:10:13 +0200
Message-ID: <200903080010.13280.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	jeffrey.t.kirsher@intel.com, e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:50496 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752789AbZCGWK3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2009 17:10:29 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel 2.6.29-rc6-git7

It will get stuck at=20
[   11.798229] e100 0000:05:04.0: firmware: requesting e100/d101m_ucode=
=2Ebin

GlobalOS ~ # zcat /proc/config.gz |grep FIRM
CONFIG_PREVENT_FIRMWARE_BUILD=3Dy
CONFIG_FIRMWARE_IN_KERNEL=3Dy
CONFIG_EXTRA_FIRMWARE=3D""
CONFIG_FIRMWARE_MEMMAP=3Dy

Most important point:
=E2=94=82 CONFIG_FIRMWARE_IN_KERNEL:                                   =
                                                                       =
                                                               =20
=E2=94=82 The kernel source tree includes a number of firmware 'blobs' =
                                                                       =
                                                               =20
=E2=94=82 which are used by various drivers. The recommended way to    =
                                                                       =
                                                               =20
=E2=94=82 use these is to run "make firmware_install" and to copy the  =
                                                                       =
                                                               =20
=E2=94=82 resulting binary files created in usr/lib/firmware directory =
                                                                       =
                                                               =20
=E2=94=82 of the kernel tree to the /lib/firmware on your system so    =
                                                                       =
                                                               =20
=E2=94=82 that they can be loaded by userspace helpers on request.     =
                                                                       =
                                                               =20
=E2=94=82 Enabling this option will build each required firmware blob  =
                                                                       =
                                                               =20
=E2=94=82 into the kernel directly, where request_firmware() will find =
                                                                       =
                                                               =20
=E2=94=82 them without having to call out to userspace. This may be    =
                                                                       =
                                                               =20
=E2=94=82 useful if your root file system requires a device which uses =
                                                                       =
                                                               =20
=E2=94=82 such firmware, and do not wish to use an initrd.             =
                                                                       =
                                                             =20

Another thing, while requesting firmware, if firmware file not availabl=
e, all=20
networking and kernel tasks is dying (no keyboards events, traffic not=20
passing over and etc). I dont think it is normal behavior.
