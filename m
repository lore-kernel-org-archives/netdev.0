From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Please pull - generic HDLC
Date: Sun, 12 Oct 2008 23:12:16 +0200
Message-ID: <m33aj15xhr.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:50906 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752369AbYJLVMT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Oct 2008 17:12:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

The following changes since commit
f3073ac76755abd63b1d4c3d145f4c15b65b5355 (i.e., your netdev-2.6):
Guennadi Liakhovetski (1): smc911x: Fix external PHY detection

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/chris/linux-2.6.git for=
-david

Summary:
a) generic HDLC includes that newer PPP code, and now, with all
   drivers ported, syncppp can finally be removed
b) drivers for cards based on Hitachi/Renesas SCA and SCA-II chips are
   split and reworked. Means nothing or almost nothing to SCA-based
   cards (=3D ISA etc), and some updates including NAPI to PCI cards
   based on SCA-II (their are low speed but NAPI saves them when the
   card is being fed with a continuous stream of errors).
c) the relevant part of Wang Chen's dev->priv conversion batch

Posted on netdev, in "next" for months, all reported probles fixed.

Please pull, TIA.


Krzysztof Ha=B3asa (15):
      WAN: split hd6457x.c into hd64570.c and hd64572.c
      WAN: remove SCA II support from SCA drivers
      WAN: remove SCA support from SCA-II drivers
      WAN: convert HD64572-based drivers to NAPI.
      WAN: TX-done handler now uses the ownership bit in HD64572 driver=
s.
      WAN: HD64572 already handles TX underruns with DMAC.
      WAN: rework HD64572 interrupts a bit.
      WAN: Simplify HD64572 status handling.
      WAN: don't print HD64572 driver versions anymore.
      WAN: Simplify HD64572 drivers.
      WAN: HD64572 drivers don't use next_desc() anymore.
      WAN: Correct comments in hd6457[02].c
      WAN: Simplify sca_init_port() in HD64572 driver.
      WAN: new synchronous PPP implementation for generic HDLC.
      WAN: syncppp.c is no longer used by any kernel code. Remove it.

Wang Chen (2):
      netdevice hdlc: Convert directly reference of netdev->priv to net=
dev->ml_priv
      netdevice pc300: Convert directly reference of netdev->priv to ne=
tdev->ml_priv

 Documentation/DocBook/Makefile            |    2 +-
 Documentation/DocBook/networking.tmpl     |    3 -
 Documentation/DocBook/wanbook.tmpl        |   99 --
 Documentation/networking/generic-hdlc.txt |    8 +-
 drivers/net/wan/Makefile                  |    2 +-
 drivers/net/wan/c101.c                    |    6 +-
 drivers/net/wan/{hd6457x.c =3D> hd64570.c}  |  254 ++----
 drivers/net/wan/hd64572.c                 |  641 +++++++++++++
 drivers/net/wan/hdlc_fr.c                 |   10 +-
 drivers/net/wan/hdlc_ppp.c                |  648 ++++++++++++-
 drivers/net/wan/n2.c                      |    9 +-
 drivers/net/wan/pc300_drv.c               |   17 +-
 drivers/net/wan/pc300too.c                |   73 +-
 drivers/net/wan/pci200syn.c               |   77 +-
 drivers/net/wan/syncppp.c                 | 1479 ---------------------=
--------
 include/linux/hdlc.h                      |    2 +-
 include/net/syncppp.h                     |  102 --
 17 files changed, 1372 insertions(+), 2060 deletions(-)

 delete Documentation/DocBook/wanbook.tmpl
 rename drivers/net/wan/{hd6457x.c =3D> hd64570.c} (78%)
 create drivers/net/wan/hd64572.c (hd6457x.c split into these two)
 delete drivers/net/wan/syncppp.c
 delete include/net/syncppp.h
--=20
Krzysztof Halasa
