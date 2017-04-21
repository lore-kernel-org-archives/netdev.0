From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 21 Apr 2017 15:56:16 -0400 (EDT)
Message-ID: <20170421.155616.1300464696171653706.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37870 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425689AbdDUT42 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:56:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Don't race in IPSEC dumps, from Yuejie Shi.

2) Verify lengths properly in IPSEC reqeusts, from Herbert Xu.

3) Fix out of bounds access in ipv6 segment routing code, from David
   Lebrun.

4) Don't write into the header of cloned SKBs in smsc95xx driver, from
   James Hughes.

5) Several other drivers have this bug too, fix them.  From Eric
   Dumazet.

6) Fix access to uninitialized data in TC action cookie code, from
   Wolfgang Bumiller.

7) Fix double free in IPV6 segment routing, again from David Lebrun.

8) Don't let userspace set the RTF_PCPU flag, oops.  From David Ahern.

9) Fix use after free in qrtr code, from Dan Carpenter.

10) Don't double-destroy devices in ip6mr code, from Nikolay
    Aleksandrov.

11) Don't pass out-of-range TX queue indices into drivers, from Tushar
    Dave.

Please pull, thanks a lot!

The following changes since commit 005882e53d62f25dae10351a8d3f13326051e8f5:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc (2017-04-18 13:56:51 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net 

for you to fetch changes up to c70b17b775edb21280e9de7531acf6db3b365274:

  netpoll: Check for skb->queue_mapping (2017-04-21 15:45:19 -0400)

----------------------------------------------------------------
Dan Carpenter (2):
      dp83640: don't recieve time stamps twice
      net: qrtr: potential use after free in qrtr_sendmsg()

Daniel Borkmann (1):
      bpf, doc: update bpf maintainers entry

David Ahern (1):
      net: ipv6: RTF_PCPU should not be settable from userspace

David Lebrun (2):
      ipv6: sr: fix out-of-bounds access in SRH validation
      ipv6: sr: fix double free of skb after handling invalid SRH

David Miller (1):
      bpf: Fix values type used in test_maps

David S. Miller (5):
      Merge tag 'mac80211-for-davem-2017-04-18' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec
      Merge branch 'qed-dcbx-fixes'
      MAINTAINERS: Add "B:" field for networking.
      Merge branch 'skb_cow_head'

Eric Dumazet (6):
      smsc75xx: use skb_cow_head() to deal with cloned skbs
      cx82310_eth: use skb_cow_head() to deal with cloned skbs
      sr9700: use skb_cow_head() to deal with cloned skbs
      lan78xx: use skb_cow_head() to deal with cloned skbs
      ch9200: use skb_cow_head() to deal with cloned skbs
      kaweth: use skb_cow_head() to deal with cloned skbs

Herbert Xu (1):
      af_key: Fix sadb_x_ipsecrequest parsing

Ilan Tayari (1):
      gso: Validate assumption of frag_list segementation

James Hughes (1):
      smsc95xx: Use skb_cow_head to deal with cloned skbs

Johannes Berg (2):
      mac80211: fix MU-MIMO follow-MAC mode
      mac80211: reject ToDS broadcast data frames

Mike Maloney (1):
      selftests/net: Fixes psock_fanout CBPF test case

Nikolay Aleksandrov (1):
      ip6mr: fix notification device destruction

Sekhar Nori (1):
      MAINTAINERS: update entry for TI's CPSW driver

Sergei Shtylyov (1):
      sh_eth: unmap DMA buffers when freeing rings

Tushar Dave (1):
      netpoll: Check for skb->queue_mapping

Wolfgang Bumiller (1):
      net sched actions: allocate act cookie early

Yuejie Shi (1):
      af_key: Add lock to key dump

sudarsana.kalluru@cavium.com (4):
      qed: Fix possible error in populating max_tc field.
      qed: Fix sending an invalid PFC error mask to MFW.
      qed: Fix possible system hang in the dcbnl-getdcbx() path.
      qed: Fix issue in populating the PFC config paramters.

 MAINTAINERS                                |  18 +++++++++++++++--
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c |  13 +++++++++++-
 drivers/net/ethernet/renesas/sh_eth.c      | 122 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---------------------------------------------------
 drivers/net/phy/dp83640.c                  |   2 --
 drivers/net/usb/ch9200.c                   |   9 ++-------
 drivers/net/usb/cx82310_eth.c              |   7 ++-----
 drivers/net/usb/kaweth.c                   |  18 ++++++-----------
 drivers/net/usb/lan78xx.c                  |   9 ++-------
 drivers/net/usb/smsc75xx.c                 |   8 ++------
 drivers/net/usb/smsc95xx.c                 |  12 +++++------
 drivers/net/usb/sr9700.c                   |   9 ++-------
 include/uapi/linux/ipv6_route.h            |   2 +-
 net/core/netpoll.c                         |  10 ++++++++--
 net/core/skbuff.c                          |  18 +++++++++++++----
 net/ipv6/exthdrs.c                         |   1 -
 net/ipv6/ip6mr.c                           |  13 ++++++------
 net/ipv6/route.c                           |   4 ++++
 net/ipv6/seg6.c                            |   3 +++
 net/key/af_key.c                           |  93 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---------------------------
 net/mac80211/rx.c                          |  86 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-----------------
 net/qrtr/qrtr.c                            |   4 +++-
 net/sched/act_api.c                        |  55 ++++++++++++++++++++++++++++++---------------------
 tools/testing/selftests/bpf/test_maps.c    |   4 ++--
 tools/testing/selftests/net/psock_fanout.c |  22 +++++++++++++++++++--
 tools/testing/selftests/net/psock_lib.h    |  13 +++---------
 25 files changed, 345 insertions(+), 210 deletions(-)
