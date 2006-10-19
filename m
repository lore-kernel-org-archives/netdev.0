From: Olaf Hering <olaf@aepfle.de>
Subject: revert mv643xx change from ubuntu tree
Date: Thu, 19 Oct 2006 14:18:36 +0200
Message-ID: <20061019121836.GA26319@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Received: from natblert.rzone.de ([81.169.145.181]:65000 "EHLO
	natblert.rzone.de") by vger.kernel.org with ESMTP id S1423324AbWJSMUO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Oct 2006 08:20:14 -0400
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Linus Torvalds <torvalds@osdl.org>,
	Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Somehow the Ubuntu guys managed to sneak this compile error into the
tree:

commit ce9e3d9953c8cb67001719b5516da2928e956be4

      [mv643xx] Add pci device table for auto module loading.

drivers/net/mv643xx_eth.c:1560: error: array type has incomplete elemen=
t type
drivers/net/mv643xx_eth.c:1561: warning: implicit declaration of functi=
on =E2=80=98PCI_DEVICE=E2=80=99
drivers/net/mv643xx_eth.c:1561: error: =E2=80=98PCI_VENDOR_ID_MARVELL=E2=
=80=99 undeclared here (not in a function)
drivers/net/mv643xx_eth.c:1561: error: =E2=80=98PCI_DEVICE_ID_MARVELL_M=
V64360=E2=80=99 undeclared here (not in a function)


This change is also wrong, the autoloading works perfect with 2.6.18,
no need to add random PCI ids.

http://ozlabs.org/pipermail/linuxppc-dev/2006-October/026544.html

Please revert this change and route changes via jgarzik etc...
