From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Thu, 06 Nov 2008 16:08:42 -0800 (PST)
Message-ID: <20081106.160842.221582607.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40145
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753789AbYKGAIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2008 19:08:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Several fixes:

1) The dreaded __scm_destroy() recursion fix.  I'll queue this up
   for -stable too.

2) ath5k interrupt handling change revert, it causes lost beacons

2) TCP recvmsg() handling of MSG_PEEK is slightly busted.  It causes
   recvmsg() to unconditionally behave in a non-blocking manner.

   Not only does this disagree with BSD (and other BSD socket implementations),
   it is known to make certain applications misbehave.

3) Virtual interfaces coming up doesn't trigger duplicate-address-detection
   properly, fix from Benjamin Thery.

4) VLAN delivery to packet sockets is broken for non-NAPI devices, fix
   from Patrick McHardy.

5) Fix sleep in softirq in intel wireless, from John W. Linville

6) IPSEC template creation doesn't initialize the address family
   field of temporary selector, fix from Andreas Steffen.

Please pull, thanks a lot!

The following changes since commit bbb770e7ab9a436752babfc8765e422d7481be1f:
  Alexey Dobriyan (1):
        xfrm: Fix xfrm_policy_gc_lock handling.

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexey Dobriyan (1):
      netfilter: netns ct: walk netns list under RTNL

Andreas Steffen (1):
      xfrm: Have af-specific init_tempsel() initialize family field of temporary selector

Benjamin Thery (1):
      ipv6: fix run pending DAD when interface becomes ready

Bob Copeland (1):
      ath5k: correct handling of rx status fields

Daniel Drake (1):
      zd1211rw: Add 2 device IDs

David S. Miller (3):
      tcp: Fix recvmsg MSG_PEEK influence of blocking behavior.
      net: Fix recursive descent in __scm_destroy().
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6

John W. Linville (2):
      Revert "ath5k: honor FIF_BCN_PRBRESP_PROMISC in STA mode"
      iwlagn: avoid sleep in softirq context

Jonathan McDowell (1):
      Fix logic error in rfkill_check_duplicity

Mohamed Abbas (2):
      iwlwifi: clear scanning bits upon failure
      iwl3945: clear scanning bits upon failure

Patrick McHardy (1):
      net: fix packet socket delivery in rx irq handler

Randy Dunlap (1):
      net/9p: fix printk format warnings

Reinette Chatre (1):
      iwl3945: do not send scan command if channel count zero

Zhu, Yi (1):
      iwl3945: fix deadlock on suspend

 drivers/net/wireless/ath5k/base.c           |    4 ++-
 drivers/net/wireless/ath5k/desc.c           |   16 +++++-----
 drivers/net/wireless/iwlwifi/iwl-agn.c      |    6 +++-
 drivers/net/wireless/iwlwifi/iwl-scan.c     |    7 ++++
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   15 ++++++++-
 drivers/net/wireless/zd1211rw/zd_usb.c      |    2 +
 include/linux/if_vlan.h                     |    7 ++++
 include/linux/sched.h                       |    2 +
 include/net/scm.h                           |    5 ++-
 net/8021q/vlan_core.c                       |   46 +++++++++++++++++++-------
 net/9p/client.c                             |   31 +++++++++++------
 net/core/dev.c                              |    3 ++
 net/core/scm.c                              |   24 ++++++++++++--
 net/ipv4/tcp.c                              |    3 +-
 net/ipv4/xfrm4_state.c                      |    1 +
 net/ipv6/addrconf.c                         |    4 ++-
 net/ipv6/xfrm6_state.c                      |    1 +
 net/netfilter/nf_conntrack_helper.c         |    3 ++
 net/netfilter/nf_conntrack_proto.c          |    5 +++
 net/rfkill/rfkill.c                         |    2 +-
 20 files changed, 143 insertions(+), 44 deletions(-)
