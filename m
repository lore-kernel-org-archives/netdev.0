From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 00/34] Pull request for 'davem-next.base_addr.removal' branch
Date: Thu, 15 Mar 2012 14:56:57 +0100
Message-ID: <cover.1331814082.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51794 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755233Ab2CON7Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 09:59:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'davem-next.base_addr.removal' in repository

git://violet.fr.zoreil.com/romieu/linux davem-next.base_addr.removal

to get the changes below.

The base_addr, irq, ... fields from the net_device struct will not go
away tomorrow. I still have some hope that new drivers stop using them
(or abusing them, see drivers/net/ethernet/broadcom/cnic.c). This series
addresses some PCI ethernet drivers.

Most patches are few liners. I have indulged myself with some __iomem
or pci_iomap conversions.

Distance from 'davem-next' (cdf485be3a63d1f34293740fb726088c6840ceea)
---------------------------------------------------------------------

3d507c4f193d4b96c2a4679496e323e99756c470
6fbe1c856415aff0b1cf507a4687fe94cb9a384b
3d526697eb55c30b9eaa8e003519ae22cbb97f59
01b3ae027e23d903f38da93ebc9e6c0d18c940a3
4d00a4ed99e4951226860ff1580a8e507858f332
1c98b91ceb9435e5669f31d68d94f7bb9a51ef33
2e58a04f13c2d5bc31134c0169311d5ea8f6515b
4aba570ae9594788bffa6ad3b1f043e6f4fd1b9c
15bee571dc5bdd3164718b6030d994628c7ddc62
d01b498a140cc8f7245d2c05443706807f62e62a
c55334ebf0479837862671e84137f2ff3ef55279
cc6d6ac73b8297d3eda5ef20a83a1eb0587b52e9
e8b3465856499347b5e223cdc82d724308ce99b1
62c6b5fe7ebcbc0d4b5c5ecdc92b9d82e4405b4c
1febab2c8e194b96da9d418d00aee5c32c6414fa
ad0c2d0b63aea5748f5b335c6348e27d0ca6bd0e
0f2b180e691fa543beb6179a429d4efa59a791df
13067b771f01e58a2f09e0fb3041cd41dcae6c21
1c40391c12d3bbe8f47c6825b18cb4cbd9f4668b
71828a700b2e7768626050c4f1fc3e2ee914d0ae
63922b8838b7905c42491d8aa93edeb6d9297633
bbff887735ffa951d9172c17b860ef7d4d79ca47
1a1e94e57ee6239e6e0afc467431c207c792dea1
48cf326fcc518b2782b6c6d31ebaf2b75ac0a70e
a89c85314f8c3cc79c657ccf26d59422b50aa2b8
bfe92ff6fcf89b8cbbdfc6f4fd86865d26b06e1f
7b58b85fa2e4e46a9e5874a4c917bd4a415d7073
e7ff4b8be11667aa547995e0198700a1669eeae4
87fefb4f9987c8a8282d1cae8d05894f8a9d171d
de42653b37a61834aa8ebe5657111ecc4501edd2
5b3f004f647d3de0775615a26170a73be799fc0c
1fb6d9a85e2c348b073c52eaf0a06321e9bb7d0c
333fbbccca8915c988acc82e0aae84e3c4f42283
a41b1ae9c479062e3e5695ef1f1194c6df354b19

Diffstat
--------

 drivers/net/ethernet/adaptec/starfire.c         |   54 +---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    5 +-
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c |   17 +-
 drivers/net/ethernet/broadcom/bnx2.c            |   41 +--
 drivers/net/ethernet/dec/tulip/de2104x.c        |   34 +--
 drivers/net/ethernet/dec/tulip/dmfe.c           |  174 ++++++-----
 drivers/net/ethernet/dec/tulip/tulip_core.c     |   27 +-
 drivers/net/ethernet/dec/tulip/uli526x.c        |  184 ++++++------
 drivers/net/ethernet/dec/tulip/winbond-840.c    |   17 +-
 drivers/net/ethernet/dec/tulip/xircom_cb.c      |   90 ++++--
 drivers/net/ethernet/dlink/dl2k.c               |  158 +++++-----
 drivers/net/ethernet/dlink/dl2k.h               |   25 +-
 drivers/net/ethernet/dlink/sundance.c           |   12 +-
 drivers/net/ethernet/fealnx.c                   |   17 +-
 drivers/net/ethernet/natsemi/natsemi.c          |   67 +++--
 drivers/net/ethernet/neterion/s2io.c            |   14 +-
 drivers/net/ethernet/neterion/vxge/vxge-main.c  |   18 +-
 drivers/net/ethernet/nvidia/forcedeth.c         |    5 -
 drivers/net/ethernet/packetengines/hamachi.c    |   11 +-
 drivers/net/ethernet/packetengines/yellowfin.c  |   32 +--
 drivers/net/ethernet/realtek/8139cp.c           |   21 +-
 drivers/net/ethernet/realtek/8139too.c          |  136 ++++-----
 drivers/net/ethernet/silan/sc92031.c            |   35 +--
 drivers/net/ethernet/sis/sis190.c               |   26 +-
 drivers/net/ethernet/sis/sis900.c               |  375 ++++++++++++-----------
 drivers/net/ethernet/smsc/epic100.c             |  145 +++++-----
 drivers/net/ethernet/smsc/smsc9420.c            |   36 +--
 drivers/net/ethernet/sun/sungem.c               |    2 -
 drivers/net/ethernet/sun/sunhme.c               |   20 +-
 drivers/net/ethernet/sun/sunhme.h               |    1 +
 drivers/net/ethernet/tehuti/tehuti.c            |    4 -
 drivers/net/ethernet/via/via-rhine.c            |   12 +-
 drivers/net/ethernet/via/via-velocity.c         |    9 +-
 33 files changed, 881 insertions(+), 943 deletions(-)

Shortlog
--------

Francois Romieu (34):
      sungem: stop using net_device.{base_addr, irq}.
      tehuti: stop using net_device.{base_addr, irq}.
      forcedeth: stop using net_device.{base_addr, irq}.
      atl1c: stop using net_device.{base_addr, irq}.
      via-rhine: stop using net_device.{base_addr, irq}.
      hamachi: stop using net_device.{base_addr, irq}.
      via-velocity: stop using net_device.{base_addr, irq}.
      sundance: stop using net_device.{base_addr, irq}.
      vxge: stop using net_device.{base_addr, irq}.
      fealnx: stop using net_device.{base_addr, irq}.
      atl1e: stop using net_device.{base_addr, irq}.
      s2io: stop using net_device.{base_addr, irq}.
      8139cp: stop using net_device.{base_addr, irq}.
      yellowfin: stop using net_device.{base_addr, irq}.
      starfire: stop using net_device.{base_addr, irq}.
      starfire: remove deprecated options.
      bnx2: stop using net_device.{base_addr, irq}.
      winbond840: stop using net_device.{base_addr, irq}.
      sc92031: stop using net_device.{base_addr, irq}
      sis190: stop using net_device.{base_addr, irq}
      tulip_core: stop using net_device.{base_addr, irq}.
      sunhme: stop using net_device.{base_addr, irq}.
      uli526x: fix regions leak in driver probe error path.
      xircom_cb: fix device probe error path.
      xircom_cb: stop using net_device.{base_addr, irq} and convert to __iomem.
      de2104x: stop using net_device.{base_addr, irq}.
      smsc9420: stop using net_device.{base_addr, irq}.
      natsemi: stop using net_device.{base_addr, irq}.
      8139too: dev->{base_addr, irq} removal.
      dl2k: stop using net_device.{base_addr, irq} and convert to __iomem.
      uli526x: stop using net_device.{base_addr, irq} and convert to __iomem.
      epic100: stop using net_device.{base_addr, irq} and convert to __iomem.
      dmfe: stop using net_device.{base_addr, irq} and convert to __iomem.
      sis900: stop using net_device.{base_addr, irq} and convert to __iomem.

-- 
Ueimor
