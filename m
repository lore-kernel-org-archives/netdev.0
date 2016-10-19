From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next 0/6] net: use core MTU range checking everywhere
Date: Tue, 18 Oct 2016 22:33:27 -0400
Message-ID: <20161019023333.15760-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35816 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753233AbcJSCdl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Oct 2016 22:33:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This stack of patches should get absolutely everything in the kernel
converted from doing their own MTU range checking to the core MTU range
checking.

Jarod Wilson (6):
  net: use core MTU range checking in USB NIC drivers
  net: use core MTU range checking in wireless drivers
  net: use core MTU range checking in WAN drivers
  net: use core MTU range checking in core net infra
  net: use core MTU range checking in virt drivers
  net: use core MTU range checking in misc drivers

CC: netdev@vger.kernel.org

 drivers/char/pcmcia/synclink_cs.c                  |  1 -
 drivers/firewire/net.c                             | 12 +----
 drivers/infiniband/hw/nes/nes.c                    |  1 -
 drivers/infiniband/hw/nes/nes.h                    |  4 +-
 drivers/infiniband/hw/nes/nes_nic.c                | 10 ++--
 drivers/misc/sgi-xp/xpnet.c                        | 21 ++------
 drivers/net/geneve.c                               | 48 +++++++----------
 drivers/net/hippi/rrunner.c                        |  1 -
 drivers/net/hyperv/hyperv_net.h                    |  4 +-
 drivers/net/hyperv/netvsc_drv.c                    | 14 ++---
 drivers/net/macvlan.c                              |  6 ++-
 drivers/net/rionet.c                               | 15 ++----
 drivers/net/slip/slip.c                            | 11 ++--
 drivers/net/tun.c                                  | 20 +++----
 drivers/net/usb/lan78xx.c                          |  8 ++-
 drivers/net/usb/r8152.c                            | 15 ++++--
 drivers/net/usb/usbnet.c                           |  2 -
 drivers/net/virtio_net.c                           | 23 ++++----
 drivers/net/vmxnet3/vmxnet3_drv.c                  |  7 +--
 drivers/net/vxlan.c                                | 62 +++++++++++-----------
 drivers/net/wan/c101.c                             |  1 -
 drivers/net/wan/cosa.c                             |  1 -
 drivers/net/wan/dscc4.c                            |  1 -
 drivers/net/wan/farsync.c                          |  1 -
 drivers/net/wan/fsl_ucc_hdlc.c                     |  1 -
 drivers/net/wan/hdlc.c                             | 11 +---
 drivers/net/wan/hdlc_fr.c                          |  3 +-
 drivers/net/wan/hostess_sv11.c                     |  1 -
 drivers/net/wan/ixp4xx_hss.c                       |  1 -
 drivers/net/wan/lmc/lmc_main.c                     |  1 -
 drivers/net/wan/n2.c                               |  1 -
 drivers/net/wan/pc300too.c                         |  1 -
 drivers/net/wan/pci200syn.c                        |  1 -
 drivers/net/wan/sealevel.c                         |  1 -
 drivers/net/wan/wanxl.c                            |  1 -
 drivers/net/wireless/ath/wil6210/netdev.c          | 17 +-----
 drivers/net/wireless/atmel/atmel.c                 | 13 ++---
 drivers/net/wireless/cisco/airo.c                  | 14 ++---
 drivers/net/wireless/intel/ipw2x00/ipw2100.c       |  3 +-
 drivers/net/wireless/intel/ipw2x00/ipw2200.c       |  8 ++-
 drivers/net/wireless/intel/ipw2x00/libipw.h        |  1 -
 drivers/net/wireless/intel/ipw2x00/libipw_module.c |  9 ----
 drivers/staging/wlan-ng/p80211netdev.c             | 18 ++-----
 drivers/tty/synclink.c                             |  1 -
 drivers/tty/synclink_gt.c                          |  1 -
 drivers/tty/synclinkmp.c                           |  1 -
 include/linux/hdlc.h                               |  2 -
 include/linux/hippidevice.h                        |  1 -
 net/802/hippi.c                                    | 14 +----
 net/atm/lec.c                                      | 11 +---
 net/batman-adv/soft-interface.c                    | 13 +----
 net/bridge/br_device.c                             |  9 ++--
 net/openvswitch/vport-internal_dev.c               | 10 ----
 net/sched/sch_teql.c                               |  5 +-
 54 files changed, 153 insertions(+), 310 deletions(-)

-- 
2.10.0
