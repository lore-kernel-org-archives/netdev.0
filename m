From: jeffery <bucove@telus.net>
Subject: acx-20060215 for etch
Date: Fri, 15 Dec 2006 11:32:08 -0800
Message-ID: <4582F838.9050308@telus.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Received: from defout.telus.net ([204.209.205.55]:33872 "EHLO defout.telus.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030608AbWLPHf4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Dec 2006 02:35:56 -0500
To: perbj@stanford.edu, netdev@vger.kernel.org,
	acx100-devel@lists.sourceforge.net,
	acx100-users@lists.sourceforge.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pci.c needed a fix for etch..

I added the includes for utsrelease.h as they were needed for the=20
declaration of UTS_RELEASE in debian etch...

as the acx tarball downloaded into debian etch:
~~~~~~~~~~~~~

debian:/usr/src/acx-20060215# make -C /lib/modules/`uname -r`/build M=3D=
`pwd`
make: Entering directory `/usr/src/linux-headers-2.6.18-3-686'
CC [M] /usr/src/acx-20060215/pci.o
In file included from /usr/src/acx-20060215/acx.h:2,
from /usr/src/acx-20060215/pci.c:55:
/usr/src/acx-20060215/wlan_compat.h:246: warning: =91packed=92 attribut=
e=20
ignored for field of type =91u8[6]=92
/usr/src/acx-20060215/wlan_compat.h:247: warning: =91packed=92 attribut=
e=20
ignored for field of type =91u8[6]=92
/usr/src/acx-20060215/wlan_compat.h:253: warning: =91packed=92 attribut=
e=20
ignored for field of type =91u8=92


<snip>

/usr/src/acx-20060215/pci.c: In function =91acxpci_e_probe=92:
/usr/src/acx-20060215/pci.c:1653: error: =91UTS_RELEASE=92 undeclared (=
first=20
use in this function)
/usr/src/acx-20060215/pci.c:1653: error: (Each undeclared identifier is=
=20
reported only once
/usr/src/acx-20060215/pci.c:1653: error: for each function it appears i=
n.)
make[1]: *** [/usr/src/acx-20060215/pci.o] Error 1
make: *** [_module_/usr/src/acx-20060215] Error 2
make: Leaving directory `/usr/src/linux-headers-2.6.18-3-686'
debian:/usr/src/acx-20060215#

~~~~~~~~~~~

after researching and discovering these declarations had been put into=20
separate includes.h for etch,
I entered pci.c and in the includes header added the line

#include <linux/utsrelease.h>

and it compiled beautifully.
I haven't touched source code for over 12 years.
Totally made my day.



=2E..jeffery
