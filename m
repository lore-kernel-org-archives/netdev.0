From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [Pull request] WAN aka generic HDLC (next)
Date: Thu, 13 Nov 2008 22:48:50 +0100
Message-ID: <m3ej1f9u0t.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:47122 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751626AbYKMVsx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Nov 2008 16:48:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

Can you pull my WAN tree into "next", please?

The following changes since Linux 2.6.28-rc4
are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/chris/linux-2.6.git for-jeff

me (15):
      WAN: split hd6457x.c into hd64570.c and hd64572.c
      WAN: remove SCA II support from SCA drivers
      WAN: remove SCA support from SCA-II drivers
      WAN: convert HD64572-based drivers to NAPI.
      WAN: TX-done handler now uses the ownership bit in HD64572 drivers.
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
      netdevice hdlc: Convert directly reference of netdev->priv to netdev->ml_priv
      netdevice pc300: Convert directly reference of netdev->priv to netdev->ml_priv

 Documentation/DocBook/Makefile            |    2 +-
 Documentation/DocBook/networking.tmpl     |    3 -
 Documentation/DocBook/wanbook.tmpl        |   99 --
 Documentation/networking/generic-hdlc.txt |    8 +-
 drivers/net/wan/Makefile                  |    2 +-
 drivers/net/wan/c101.c                    |    6 +-
 drivers/net/wan/{hd6457x.c => hd64570.c}  |  254 ++----
 drivers/net/wan/hd64572.c                 |  641 +++++++++++++
 drivers/net/wan/hdlc_fr.c                 |   10 +-
 drivers/net/wan/hdlc_ppp.c                |  648 ++++++++++++-
 drivers/net/wan/n2.c                      |    9 +-
 drivers/net/wan/pc300_drv.c               |   17 +-
 drivers/net/wan/pc300too.c                |   73 +-
 drivers/net/wan/pci200syn.c               |   77 +-
 drivers/net/wan/syncppp.c                 | 1480 -----------------------------
 include/linux/hdlc.h                      |    2 +-
 include/net/syncppp.h                     |  102 --
 17 files changed, 1372 insertions(+), 2061 deletions(-)
 delete mode 100644 Documentation/DocBook/wanbook.tmpl
 rename drivers/net/wan/{hd6457x.c => hd64570.c} (78%)
 create mode 100644 drivers/net/wan/hd64572.c
 delete mode 100644 drivers/net/wan/syncppp.c
 delete mode 100644 include/net/syncppp.h

This is basically:
- updates to Hitachi/Renesas SCA/SCA-II-based drivers (including
  hd6457x.c split into hd64570.c and hd64572.c)
- the second=last part of syncppp conversion (all drivers are already
  using hdlc_ppp)
- smaller things

Rebased to v2.6.28-rc4 to resolve pre-rc4 conflicts (syncppp.c and
wanbook.tmpl deletion), hope that's ok.

Thanks.
-- 
Krzysztof Halasa
