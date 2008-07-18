From: Stefan Roese <sr@denx.de>
Subject: Re: e1000e "Detected Tx Unit Hang"
Date: Fri, 18 Jul 2008 16:55:54 +0200
Message-ID: <200807181655.54760.sr@denx.de>
References: <4866211E.6040704@embedded-sol.com> <200807140947.46733.sr@denx.de> <487B0B75.1070506@embedded-sol.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org
To: Felix Radensky <felix@embedded-sol.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.174]:52287 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751776AbYGRO4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 10:56:12 -0400
In-Reply-To: <487B0B75.1070506@embedded-sol.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Felix,

On Monday 14 July 2008, Felix Radensky wrote:
> >> The following command works always
> >>
> >> dd if=/dev/zero of=/mnt/test bs=512 count=2
> >>
> >> and the following causes Tx unit hang
> >>
> >>  dd if=/dev/zero of=/mnt/test bs=512 count=3
> >>
> >> Stefan, are you aware of any PCIe related problems on Canyonlands ?
> >> AMCC have compatibility chart on their site, which indicates that this
> >> particular card (Intel PRO/1000 T Desktop Adapter) Iwas tested with
> >> linux-2.6.25 kernel.

I just tried this on my Canyonlands with the kernel.org 2.6.26 release:

e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k2
e1000e: Copyright (c) 1999-2008 Intel Corporation.
e1000e 0001:81:00.0: enabling device (0006 -> 0007)
eth0: (PCI Express:2.5GB/s:Width x1) 00:1b:21:04:a3:47
eth0: Intel(R) PRO/1000 Network Connection
eth0: MAC: 1, PHY: 4, PBA No: d50854-003
...

-bash-3.2# uname -a
Linux canyonlands 2.6.26 #2 Fri Jul 18 16:46:00 CEST 2008 ppc ppc ppc GNU/Linux
-bash-3.2# dd if=/dev/zero of=/mnt/test bs=512 count=2
2+0 records in
2+0 records out
1024 bytes (1.0 kB) copied, 0.015222 s, 67.3 kB/s
-bash-3.2# dd if=/dev/zero of=/mnt/test bs=512 count=3
3+0 records in
3+0 records out
1536 bytes (1.5 kB) copied, 0.014824 s, 104 kB/s
-bash-3.2# dd if=/dev/zero of=/mnt/test bs=512 count=256
256+0 records in
256+0 records out
131072 bytes (131 kB) copied, 0.099793 s, 1.3 MB/s
-bash-3.2# dmesg -c
-bash-3.2#                                      

So no problems here.

Rootfs NFS is mounted via e1000e of course.

Did you try with kernel.org 2.6.26 too? If not, please do so.

Best regards,
Stefan

=====================================================================
DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
Phone: +49-8142-66989-0 Fax: +49-8142-66989-80  Email: office@denx.de
=====================================================================
