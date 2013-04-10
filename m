From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 10 Apr 2013 15:49:22 -0400 (EDT)
Message-ID: <20130410.154922.1761310080766751754.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51718 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935153Ab3DJTtZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 15:49:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) cfg80211_conn_scan() must be called with the sched_scan_mutex, fix
   from Artem Savkov.

2) Fix regression in TCP ICMPv6 processing, we do not want to treat
   redirects as socket errors, from Christoph Paasch.

3) Fix several recvmsg() msg_name kernel memory leaks into userspace,
   in ATM, AX25, Bluetooth, CAIF, IRDA, s390 IUCV, L2TP, LLC, Netrom,
   NFC, Rose, TIPC, and VSOCK.  From Mathias Krause and Wei Yongjun.

4) Fix AF_IUCV handling of segmented SKBs in recvmsg(), from Ursula
   Braun and Eric Dumazet.

5) CAN gw.c code does kfree() on SLAB cache memory, use
   kmem_cache_free() instead.  Fix from Wei Yongjun.

6) Fix LSM regression on TCP SYN/ACKs, some LSMs such as SELINUX want
   an skb->sk socket context available for these packets, but nothing
   else requires it.  From Eric Dumazet and Paul Moore.

7) Fix ipv4 address lifetime processing so that we don't perform
   sleepable acts inside of rcu_read_lock() sections, do them in an
   rtnl_lock() section instead.  From Jiri Pirko.

8) mvneta driver accidently sets HW features after device registry,
   it should do so beforehand.  Fix from Willy Tarreau.

9) Fix bonding unload races more correctly, from Nikolay Aleksandrov
   and Veaceslav Falico.

10) rtnl_dump_ifinfo() and rtnl_calcit() invoke nlmsg_parse() with wrong
    header size argument.  Fix from Michael Riesch.

Please pull, thanks a lot!

The following changes since commit 53f63189b1110559dce8c1ee29e8abc3e31f7630:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2013-04-05 14:04:10 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 6b07a24fc38476e04f591cc17594bc1835b9efdd:

  lsm: add the missing documentation for the security_skb_owned_by() hook (2013-04-10 15:40:39 -0400)

----------------------------------------------------------------
Artem Savkov (1):
      cfg80211: sched_scan_mtx lock in cfg80211_conn_work()

Bing Zhao (1):
      mwifiex: complete last internal scan

Christoph Paasch (1):
      ipv6/tcp: Stop processing ICMPv6 redirect messages

David S. Miller (3):
      Merge branch 'infoleaks'
      Merge branch 'wireless'
      Merge branch 'fixes-for-3.9' of git://gitorious.org/linux-can/linux-can

Eric Dumazet (1):
      selinux: add a skb_owned_by() hook

Franky Lin (1):
      brcmfmac: do not proceed if fail to download nvram to dongle

Gabor Juhos (1):
      rt2x00: rt2x00pci: fix build error on Ralink RT3x5x SoCs

Haiyang Zhang (2):
      hyperv: Fix a kernel warning from netvsc_linkstatus_callback()
      hyperv: Fix RNDIS send_completion code path

Hante Meuleman (3):
      brcmfmac: fix tkip mic tx/rx ap swap bug.
      brcmfmac: fix stopping AP.
      brcmfmac: fix returning cipher_suite for get_key operation.

Jiri Pirko (2):
      net: ipv4: reset check_lifetime_work after changing lifetime
      net: ipv4: fix schedule while atomic bug in check_lifetime()

John W. Linville (2):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Mathias Krause (16):
      atm: update msg_namelen in vcc_recvmsg()
      ax25: fix info leak via msg_name in ax25_recvmsg()
      Bluetooth: fix possible info leak in bt_sock_recvmsg()
      Bluetooth: RFCOMM - Fix missing msg_namelen update in rfcomm_sock_recvmsg()
      Bluetooth: SCO - Fix missing msg_namelen update in sco_sock_recvmsg()
      caif: Fix missing msg_namelen update in caif_seqpkt_recvmsg()
      irda: Fix missing msg_namelen update in irda_recvmsg_dgram()
      iucv: Fix missing msg_namelen update in iucv_sock_recvmsg()
      l2tp: fix info leak in l2tp_ip6_recvmsg()
      llc: Fix missing msg_namelen update in llc_ui_recvmsg()
      netrom: fix info leak via msg_name in nr_recvmsg()
      NFC: llcp: fix info leaks via msg_name in llcp_sock_recvmsg()
      rose: fix info leak via msg_name in rose_recvmsg()
      tipc: fix info leaks via msg_name in recv_msg/recv_stream
      VSOCK: vmci - fix possible info leak in vmci_transport_dgram_dequeue()
      VSOCK: Fix missing msg_namelen update in vsock_stream_recvmsg()

Michael Riesch (1):
      rtnetlink: Call nlmsg_parse() with correct header length

Neil Horman (1):
      e100: Add dma mapping error check

Paul Moore (1):
      lsm: add the missing documentation for the security_skb_owned_by() hook

Robert Shade (1):
      ath9k: Re-enable interrupts after a channel change failure

Sridhar Samudrala (1):
      sctp: remove 'sridhar' from maintainers list

Stefan Raspl (1):
      qeth: fix qeth_wait_for_threads() deadlock for OSN devices

Tim Gardner (1):
      rt2x00: rt2x00pci_regbusy_read() - only print register access failure once

Ursula Braun (1):
      af_iucv: fix recvmsg by replacing skb_pull() function

Wei Yongjun (2):
      netrom: fix invalid use of sizeof in nr_recvmsg()
      can: gw: use kmem_cache_free() instead of kfree()

Yaniv Rosner (1):
      bnx2x: Fix KR2 rapid link flap

Yuval Mintz (1):
      bnx2x: Prevent null pointer dereference in AFEX mode

nikolay@redhat.com (2):
      Revert "bonding: remove sysfs before removing devices"
      bonding: fix bonding_masters race condition in bond unloading

willy tarreau (1):
      net: mvneta: enable features before registering the driver

 MAINTAINERS                                           |   1 -
 drivers/net/bonding/bond_main.c                       |  11 +++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c      |  18 +++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c      |   3 +-
 drivers/net/ethernet/intel/e100.c                     |  36 ++++++++----
 drivers/net/ethernet/marvell/mvneta.c                 |   9 +--
 drivers/net/hyperv/netvsc.c                           |  17 ++++--
 drivers/net/hyperv/netvsc_drv.c                       |   2 -
 drivers/net/hyperv/rndis_filter.c                     |  14 +----
 drivers/net/wireless/ath/ath9k/main.c                 |   4 ++
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c    |   6 +-
 drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c |  46 ++++++++-------
 drivers/net/wireless/mwifiex/scan.c                   |  11 +++-
 drivers/net/wireless/rt2x00/Kconfig                   |   7 +++
 drivers/net/wireless/rt2x00/Makefile                  |   1 +
 drivers/net/wireless/rt2x00/rt2400pci.c               |   1 +
 drivers/net/wireless/rt2x00/rt2500pci.c               |   1 +
 drivers/net/wireless/rt2x00/rt2800pci.c               |   1 +
 drivers/net/wireless/rt2x00/rt2x00mmio.c              | 216 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/wireless/rt2x00/rt2x00mmio.h              | 119 +++++++++++++++++++++++++++++++++++++
 drivers/net/wireless/rt2x00/rt2x00pci.c               | 176 ------------------------------------------------------
 drivers/net/wireless/rt2x00/rt2x00pci.h               |  88 ---------------------------
 drivers/net/wireless/rt2x00/rt61pci.c                 |   1 +
 drivers/s390/net/qeth_core.h                          |   3 +
 drivers/s390/net/qeth_core_main.c                     |  19 ++++++
 drivers/s390/net/qeth_l2_main.c                       |   2 +
 drivers/s390/net/qeth_l3_main.c                       |   2 +
 include/linux/security.h                              |  12 ++++
 include/net/iucv/af_iucv.h                            |   8 +++
 net/atm/common.c                                      |   2 +
 net/ax25/af_ax25.c                                    |   1 +
 net/bluetooth/af_bluetooth.c                          |   4 +-
 net/bluetooth/rfcomm/sock.c                           |   1 +
 net/bluetooth/sco.c                                   |   1 +
 net/caif/caif_socket.c                                |   2 +
 net/can/gw.c                                          |   6 +-
 net/core/rtnetlink.c                                  |   4 +-
 net/ipv4/devinet.c                                    |  60 ++++++++++++++-----
 net/ipv4/tcp_output.c                                 |   1 +
 net/ipv6/tcp_ipv6.c                                   |   1 +
 net/irda/af_irda.c                                    |   2 +
 net/iucv/af_iucv.c                                    |  36 ++++++------
 net/l2tp/l2tp_ip6.c                                   |   1 +
 net/llc/af_llc.c                                      |   2 +
 net/netrom/af_netrom.c                                |   1 +
 net/nfc/llcp/sock.c                                   |   3 +
 net/rose/af_rose.c                                    |   1 +
 net/tipc/socket.c                                     |   7 +++
 net/vmw_vsock/af_vsock.c                              |   2 +
 net/vmw_vsock/vmci_transport.c                        |   3 +-
 net/wireless/sme.c                                    |   2 +
 security/capability.c                                 |   6 ++
 security/security.c                                   |   5 ++
 security/selinux/hooks.c                              |   7 +++
 54 files changed, 619 insertions(+), 377 deletions(-)
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00mmio.c
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00mmio.h
