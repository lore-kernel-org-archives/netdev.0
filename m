From: David Miller <davem@davemloft.net>
Subject: [GIT PULL] Networking
Date: Fri, 22 Aug 2014 11:47:11 -0700 (PDT)
Message-ID: <20140822.114711.856705392345846995.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53092 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbaHVSrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 14:47:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here are some bug fixes that have piled up during ksummit/linuxcon.

1) Fix endian problems in ibmveth, from Anton Blanchard.

2) IPV6 routing code does GFP_KERNEL allocation in atomic, fix from Benjamin Block.

3) SCTP association fixes from Daniel Borkmann.

4) When multiple VLAN headers are present we have to make sure the second
   and subsequent ones are pullable in the SKB otherwise we blindly dereference
   garbage.  From Jiri Benc.

5) The argument adjustment of the signature of hlist_add_after*()
   introduced a regression in the batman-adv code, fix from Sven
   Eckelmann.

6) Fix TX hang handling to avoid a panic in i40e, from Anjali Singhai Jain.

7) PTP flag test is inverted in i40e driver, from Jesse Brandeburg.

8) ATM LEC driver needs to hold RTNL mutex over MTU changes, from Chas
   Williams.

9) Truncate packets larger then the TPACKET_V3 format configured
   buffers, otherwise we overwrite past the end of said buffers.  From
   Eric Dumazet.

10) Fix endianness bugs in qlcnic firmware handling, from Rajesh
    Borundia and Shahed Shaikh.

11) CXGB4 sometimes doesn't get all of the TX completion events it
    should resulting in SKBs getting stuck in the TX queue, from
    Hariprasad Shenai.

12) When the FEC chip's PTP clock is disabled, you can't access the
    register.  Add necessary checks to avoid the resulting hang,
    from Fugang Duan.

Please pull, thanks a lot!

The following changes since commit c9d26423e56ce1ab4d786f92aebecf859d419293:

  Merge tag 'pm+acpi-3.17-rc1-2' of git://git.kernel.org/pub/scm/linux/kernel/git/rafael/linux-pm (2014-08-14 18:13:46 -0600)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to faaa55241f3a6fb5bbe5b075d0595199821eb585:

  drivers: isdn: eicon: xdi_msg.h: Fix typo in #ifndef (2014-08-22 11:31:30 -0700)

----------------------------------------------------------------
Alan Ott (1):
      MAINTAINERS: Add section for MRF24J40 IEEE 802.15.4 radio driver

Alexander Stein (1):
      can: flexcan: Disable error interrupt when bus error reporting is disabled

Anish Bhatt (1):
      cxgb4: Fix race condition in cleanup

Anjali Singhai Jain (2):
      i40e: Fix for recent kernel panic
      i40e: Fix a few potential VF dereferences

Anton Blanchard (1):
      ibmveth: Fix endian issues with rx_no_buffer statistic

Benjamin Block (1):
      net: ipv6: fib: don't sleep inside atomic lock

Dan Carpenter (1):
      can: c_can: checking IS_ERR() instead of NULL

Daniel Borkmann (2):
      net: sctp: spare unnecessary comparison in sctp_trans_elect_best
      net: sctp: fix suboptimal edge-case on non-active active/retrans path selection

Dariusz Marcinkiewicz (1):
      MAINTAINERS: add entry for ec_bhf driver

David S. Miller (6):
      Merge branch 'bcm7xxx'
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/net
      Merge branch 'cbq-fixes'
      tipc: Fix build.
      Merge branch 'qlcnic'
      Merge tag 'linux-can-fixes-for-3.17-20140821' of git://gitorious.org/linux-can/linux-can

Eric Dumazet (1):
      packet: handle too big packets for PACKET_V3

Erik Hugne (1):
      tipc: fix message importance range check

Florian Fainelli (3):
      net: phy: bcm7xxx: remove 28nm wildcard entry
      net: phy: bcm7xxx: re-advertise all supported modes out of suspend
      net: phy: bcm7xxx: remove suspend callback for 28nm PHYs

Gwenhael Goavec-Merou (1):
      net: phy: smsc: move smsc_phy_config_init reset part in a soft_reset function

Hariprasad Shenai (1):
      cxgb4: Free completed tx skbs promptly

Iyappan Subramanian (1):
      net: xgene: fix possible NULL dereference in xgene_enet_free_desc_rings()

Jesse Brandeburg (1):
      i40e: fix PTP bug

Jiri Benc (1):
      openvswitch: fix panic with multiple vlan headers

Jitendra Kalsaria (1):
      qlcnic: Fix flash access interface to application

Mirza Krak (1):
      can: sja1000: Validate initialization state in start method

Nimrod Andy (1):
      net: fec: ptp: avoid register access when ipg clock is disabled

Rajesh Borundia (1):
      qlcnic: Fix endianess issue in FW dump template header

Rasmus Villemoes (2):
      net: ethernet: broadcom: bnx2x: Remove redundant #ifdef
      drivers: isdn: eicon: xdi_msg.h: Fix typo in #ifndef

Sebastian Andrzej Siewior (1):
      can: flexcan: handle state passive -> warning transition

Shahed Shaikh (1):
      qlcnic: Fix endianess issue in firmware load from file operation

Sven Eckelmann (1):
      batman-adv: Fix parameter order of hlist_add_behind

Vasily Averin (2):
      cbq: incorrectly low bandwidth setting blocks limited traffic
      cbq: now_rt removal

Vlad Yasevich (1):
      macvlan: Allow setting multicast filter on all macvlan types

Yuval Mintz (1):
      bnx2x: Revert UNDI flushing mechanism

chas williams - CONTRACTOR (1):
      lec: Use rtnl lock/unlock when updating MTU

zhuyj (1):
      sctp: not send SCTP_PEER_ADDR_CHANGE notifications with failed probe

 MAINTAINERS                                           | 12 ++++++++
 drivers/isdn/hardware/eicon/xdi_msg.h                 |  2 +-
 drivers/net/can/c_can/c_can_platform.c                |  2 +-
 drivers/net/can/flexcan.c                             |  9 ++++++
 drivers/net/can/sja1000/sja1000.c                     | 62 ++++++++++++++++++++------------------
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c      | 20 ++++++++-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c       |  4 ---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c      | 92 +++++++++++----------------------------------------------
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h            |  1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c       | 32 +++++++++++---------
 drivers/net/ethernet/chelsio/cxgb4/sge.c              |  3 +-
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h         |  1 +
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c            |  3 +-
 drivers/net/ethernet/freescale/fec.h                  |  5 +++-
 drivers/net/ethernet/freescale/fec_main.c             | 18 +++++++++--
 drivers/net/ethernet/freescale/fec_ptp.c              | 33 ++++++++++++++-------
 drivers/net/ethernet/ibm/ibmveth.c                    | 18 ++++++++---
 drivers/net/ethernet/intel/i40e/i40e_ptp.c            |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c    | 44 +++++++++++++++++++--------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h           | 15 +++++++++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c   |  6 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c | 35 +++++++++++++++-------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c  | 57 +++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c     | 16 +++++++++-
 drivers/net/macvlan.c                                 | 10 +++++--
 drivers/net/phy/bcm7xxx.c                             | 42 +++++++++++++-------------
 drivers/net/phy/smsc.c                                | 33 +++++++++++++--------
 include/linux/brcmphy.h                               |  1 -
 net/atm/lec.c                                         |  2 ++
 net/batman-adv/fragmentation.c                        |  2 +-
 net/ipv6/ip6_fib.c                                    |  2 +-
 net/openvswitch/actions.c                             |  5 ++++
 net/packet/af_packet.c                                | 17 +++++++++++
 net/packet/internal.h                                 |  1 +
 net/sched/sch_cbq.c                                   | 48 +++++++++---------------------
 net/sctp/associola.c                                  | 12 ++++----
 net/tipc/port.h                                       |  5 +++-
 net/tipc/socket.c                                     |  2 +-
 38 files changed, 413 insertions(+), 261 deletions(-)
