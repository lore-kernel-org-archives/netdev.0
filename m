From: Karsten Keil <keil@b1-systems.de>
Subject: [mISDN PATCH v2 00/19] mISDN patchset for next
Date: Fri, 22 May 2009 22:42:47 +0200
Message-ID: <cover.1243024967.git.kkeil@pingi.linux-pingi.de>
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	i4ldeveloper@listserv.isdn4linux.de
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758085AbZEVVE7@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a update of the mISDN driver for net-next.
It syncs the mISDN driver with the development on git.misdn.org.
More updates (new hardware support) will follow.

You can pull it from 
git://master.kernel.org/pub/scm/linux/kernel/git/kkeil/ISDN-2.6-net-next.git for_dave

Andreas Eversberg (12):
  Add watchdog functionality to hfcmulti driver
  DSP now uses ring buffer for echo canceler
  Echo canceler now gets delay information from hardware
  Fixed missing spin lock on pipeline process
  Added layer-1-hold feature
  Fix DTMF locking bug issue
  Hardware acceleration is now possible in conjunction with audio
    recording
  Fix TEI and SAPI handling
  Add "sapi" information to debug messages
  Add PCI ID for Junghanns 8S card
  Added PCI ID for new Junghanns.net Single E1 cards.
  Fix DTMF detection enable/disable

Arnaldo Carvalho de Melo (1):
  Use kernel_{send,recv}msg instead of open coding

Frank Seidel (2):
  Reduce stack size in dsp_cmx_send()
  Add allocation of recvbuf[1500] at run time to reduce stack size

Karsten Keil (3):
  Fix skb leak in error cases
  Add XHFC support for embedded Speech-Design board to hfcmulti
  Cleanup debug messages

Roel Kluin (1):
  isdn: get_free_devid() failure ignored

 drivers/isdn/hardware/mISDN/Kconfig         |   11 +-
 drivers/isdn/hardware/mISDN/hfc_multi.h     |   47 ++-
 drivers/isdn/hardware/mISDN/hfc_multi_8xx.h |  167 ++++++++
 drivers/isdn/hardware/mISDN/hfcmulti.c      |  614 ++++++++++++++++++---------
 drivers/isdn/hardware/mISDN/hfcpci.c        |   98 +++--
 drivers/isdn/hardware/mISDN/hfcsusb.c       |    4 +-
 drivers/isdn/mISDN/core.c                   |    8 +-
 drivers/isdn/mISDN/dsp.h                    |   19 +-
 drivers/isdn/mISDN/dsp_audio.c              |    5 +-
 drivers/isdn/mISDN/dsp_cmx.c                |  115 ++++--
 drivers/isdn/mISDN/dsp_core.c               |   72 ++--
 drivers/isdn/mISDN/dsp_dtmf.c               |    3 +
 drivers/isdn/mISDN/dsp_ecdis.h              |    2 +-
 drivers/isdn/mISDN/dsp_pipeline.c           |    5 +-
 drivers/isdn/mISDN/dsp_tones.c              |   23 +-
 drivers/isdn/mISDN/hwchannel.c              |    4 +-
 drivers/isdn/mISDN/l1oip.h                  |    2 +-
 drivers/isdn/mISDN/l1oip_codec.c            |    1 +
 drivers/isdn/mISDN/l1oip_core.c             |   71 ++--
 drivers/isdn/mISDN/layer2.c                 |   37 +-
 drivers/isdn/mISDN/layer2.h                 |    2 +-
 drivers/isdn/mISDN/socket.c                 |   45 ++-
 drivers/isdn/mISDN/tei.c                    |   80 +++--
 drivers/isdn/mISDN/timerdev.c               |    2 +-
 include/linux/mISDNdsp.h                    |    4 +-
 include/linux/mISDNhw.h                     |    2 +-
 include/linux/mISDNif.h                     |   19 +-
 include/linux/pci_ids.h                     |    2 +
 28 files changed, 994 insertions(+), 470 deletions(-)
 create mode 100644 drivers/isdn/hardware/mISDN/hfc_multi_8xx.h
