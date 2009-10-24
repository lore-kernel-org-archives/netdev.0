From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [RFC] more PCMCIA cleanup patches for 2.6.33
Date: Sat, 24 Oct 2009 21:42:19 +0200
Message-ID: <20091024194219.GA19546@comet.dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-serial@vger.kernel.org, linux-ide@vger.kernel.org
To: linux-pcmcia@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar.linta.de ([213.133.102.198]:55677 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752012AbZJXTnV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Oct 2009 15:43:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hej,

In addition to the patches already submitted as RFC on Oct 19th, I'm
interested in your input to this patch series. They'll be sent to the
PCMCIA list shortly, with CC to other lists if deemed appropriate. If
all goes well, I'll ask Linus to pull both patch series once 2.6.32
is released.

      pcmcia: use dynamic debug instead of custom infrastructure
      pcmcia: use dynamic debug in PCMCIA socket drivers
      pcmcia: extend error reporting and debug messages in core
      pcmcia: use dynamic debug infrastructure, deprecate CS_CHECK (ide)
      pcmcia: deprecate CS_CHECK (bluetooth)
      pcmcia: use dynamic debug infrastructure, deprecate CS_CHECK (char)
      pcmcia: use dynamic debug infrastructure, deprecate CS_CHECK (isdn)
      pcmcia: use dynamic debug infrastructure, deprecate CS_CHECK (net)
      pcmcia: use dynamic debug infrastructure, deprecate CS_CHECK (ray-cs.c)
      pcmcia: use dynamic debug infrastructure, deprecate CS_CHECK (wireless)
      pcmcia: use dynamic debug infrastructure, deprecate CS_CHECK (scsi)
      pcmcia: use dynamic debug infrastructure, deprecate CS_CHECK (serial_cs)
      pcmcia: use dynamic debug infrastructure, deprecate CS_CHECK (sound)
      pcmcia: use dynamic debug infrastructure, deprecate CS_CHECK (misc drivers)
      pcmcia: remove now-defunct cs_error, pcmcia_error_{func,ret}
      pcmcia: use dev_dbg and dev_print in pd6729.c

 Documentation/pcmcia/driver-changes.txt    |    5 +
 drivers/ata/pata_pcmcia.c                  |   16 +-
 drivers/bluetooth/bluecard_cs.c            |   12 +-
 drivers/bluetooth/bt3c_cs.c                |    9 +-
 drivers/bluetooth/btuart_cs.c              |    9 +-
 drivers/bluetooth/dtl1_cs.c                |    8 +-
 drivers/char/pcmcia/cm4000_cs.c            |   69 ++----
 drivers/char/pcmcia/cm4040_cs.c            |   42 ++--
 drivers/char/pcmcia/ipwireless/main.c      |   34 +--
 drivers/char/pcmcia/synclink_cs.c          |   23 +-
 drivers/ide/ide-cs.c                       |   32 +--
 drivers/isdn/hardware/avm/avm_cs.c         |    2 -
 drivers/isdn/hisax/avma1_cs.c              |   26 +--
 drivers/isdn/hisax/elsa_cs.c               |   45 +---
 drivers/isdn/hisax/sedlbauer_cs.c          |   58 ++---
 drivers/isdn/hisax/teles_cs.c              |   37 +---
 drivers/mtd/maps/pcmciamtd.c               |   14 +-
 drivers/net/pcmcia/3c574_cs.c              |   66 +++---
 drivers/net/pcmcia/3c589_cs.c              |   75 ++----
 drivers/net/pcmcia/axnet_cs.c              |   53 ++---
 drivers/net/pcmcia/com20020_cs.c           |   55 ++---
 drivers/net/pcmcia/fmvj18x_cs.c            |  109 +++------
 drivers/net/pcmcia/ibmtr_cs.c              |   54 ++---
 drivers/net/pcmcia/nmclan_cs.c             |  148 +++++-------
 drivers/net/pcmcia/pcnet_cs.c              |   67 ++----
 drivers/net/pcmcia/smc91c92_cs.c           |   85 +++-----
 drivers/net/pcmcia/xirc2ps_cs.c            |  111 ++++------
 drivers/net/wireless/airo_cs.c             |   48 ++---
 drivers/net/wireless/atmel_cs.c            |   46 ++---
 drivers/net/wireless/hostap/hostap_cs.c    |   23 +--
 drivers/net/wireless/netwave_cs.c          |   88 +++----
 drivers/net/wireless/orinoco/orinoco_cs.c  |   27 +--
 drivers/net/wireless/orinoco/spectrum_cs.c |   54 +++---
 drivers/net/wireless/ray_cs.c              |  347 ++++++++++++++--------------
 drivers/net/wireless/wavelan_cs.c          |   24 --
 drivers/net/wireless/wl3501_cs.c           |   67 ++----
 drivers/parport/parport_cs.c               |   37 +--
 drivers/pcmcia/Kconfig                     |   36 ++--
 drivers/pcmcia/cardbus.c                   |    4 +-
 drivers/pcmcia/cistpl.c                    |   10 +-
 drivers/pcmcia/cs.c                        |   60 +++---
 drivers/pcmcia/cs_internal.h               |   22 --
 drivers/pcmcia/ds.c                        |  188 +++------------
 drivers/pcmcia/i82365.c                    |   37 +--
 drivers/pcmcia/m32r_cfc.c                  |  105 ++++-----
 drivers/pcmcia/m32r_pcc.c                  |   51 ++---
 drivers/pcmcia/m8xx_pcmcia.c               |   40 ++--
 drivers/pcmcia/pcmcia_ioctl.c              |   31 +--
 drivers/pcmcia/pcmcia_resource.c           |  126 ++++++-----
 drivers/pcmcia/pd6729.c                    |   69 +++---
 drivers/pcmcia/pd6729.h                    |    7 -
 drivers/pcmcia/tcic.c                      |   29 +--
 drivers/scsi/pcmcia/aha152x_stub.c         |   40 ++--
 drivers/scsi/pcmcia/fdomain_stub.c         |   43 ++---
 drivers/scsi/pcmcia/qlogic_stub.c          |   44 ++---
 drivers/scsi/pcmcia/sym53c500_cs.c         |   41 ++---
 drivers/serial/serial_cs.c                 |   53 ++---
 drivers/telephony/ixj_pcmcia.c             |   36 +--
 drivers/usb/host/sl811_cs.c                |   46 +---
 include/pcmcia/ds.h                        |   36 ---
 sound/pcmcia/pdaudiocf/pdaudiocf.c         |   21 +-
 sound/pcmcia/vx/vxpocket.c                 |   21 +-
 62 files changed, 1204 insertions(+), 2017 deletions(-)


Best,
	Dominik
