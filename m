From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 29 Nov 2010 11:15:41 -0800 (PST)
Message-ID: <20101129.111541.115930125.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33810
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751403Ab0K2TPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 14:15:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Two fixes for some exploitable cases in AF_UNIX file descriptor
   passing.  Both from Eric Dumazet.

2) DECnet uninitialized data to userspace fix from Dan Rosenberg.

3) Unit allocation passes incorrect error back to userspace, fix
   from Cyrill Gorcunov.

4) Inet port binding optimization maintains it's counters
   erroneously, fix from Nagendra Tomar.

5) Three econet CVE fixes from Phil Blundell.

6) ucc_geth halts in half-duplex due to over-aggressive fifo
   size setting, fix from Yang Li.

7) mcast/ucast Address handling fix in cxgb4vf from Casey Leedom.

8) tcp_adv_win_scale can cause undefined behavior if the
   abos() of it's value is >31 since it is used in shifts.
   Fix from Alexey Dobriyan

9) Regression in au1000_eth MAC enable register accesses, fix
   from Wolfgang Grandegger.

10) Struct initializer fix in pch_gbe from Toshiharu Okada.

11) Stack corruption bug in isdn icn driver from Steven Rostedt.

12) DCCP ACK tracking fix from Gerrit Renker.

13) HSO driver does not honor disable_net setting, from Filip Aben.

14) ath9k wireless timeout fix from Felix Fietkau.

Please pull, thanks a lot!

The following changes since commit 72083646528d4887b920deb71b37e09bc7d227bb:

  Un-inline get_pipe_info() helper function (2010-11-28 16:27:19 -0800)

are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexey Dobriyan (1):
      tcp: restrict net.ipv4.tcp_adv_win_scale (#20312)

Breno Leitao (1):
      ehea: Add some info messages and fix an issue

Casey Leedom (1):
      cxgb4vf: fix setting unicast/multicast addresses ...

Christian Lamparter (1):
      carl9170: fix virtual interface setup crash

Cyrill Gorcunov (1):
      net, ppp: Report correct error code if unit allocation failed

Dan Rosenberg (1):
      DECnet: don't leak uninitialized stack byte

Daniel Klaffenbach (1):
      ssb: b43-pci-bridge: Add new vendor for BCM4318

David S. Miller (3):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      tcp: Make TCP_MAXSEG minimum more correct.
      Merge branch 'vhost-net' of git://git.kernel.org/.../mst/vhost

Eric Dumazet (2):
      af_unix: limit unix_tot_inflight
      af_unix: limit recursion level

Felix Fietkau (1):
      ath9k: fix timeout on stopping rx dma

Filip Aben (1):
      hso: fix disable_net

Gerrit Renker (1):
      dccp: fix error in updating the GAR

Guennadi Liakhovetski (1):
      wireless: b43: fix error path in SDIO

Jiri Slaby (1):
      NET: wan/x25_asy, move lapb_unregister to x25_asy_close_tty

Michael S. Tsirkin (1):
      vhost/net: fix rcu check usage

Nagendra Tomar (1):
      inet: Fix __inet_inherit_port() to correctly increment bsockets and num_owners

Pavel Emelyanov (1):
      netns: Don't leak others' openreq-s in proc

Phil Blundell (3):
      econet: disallow NULL remote addr for sendmsg(), fixes CVE-2010-3849
      econet: fix CVE-2010-3850
      econet: fix CVE-2010-3848

Steven Rostedt (1):
      isdn: icn: Fix stack corruption bug.

Toshiharu Okada (2):
      pch_gbe dreiver: chang author
      pch_gbe driver: The wrong of initializer entry

Tracey Dent (1):
      Net: ceph: Makefile: Remove unnessary code

Wolfgang Grandegger (1):
      au1000_eth: fix invalid address accessing the MAC enable register

Yang Li (1):
      ucc_geth: fix ucc halt problem in half duplex mode

 Documentation/networking/ip-sysctl.txt   |    1 +
 drivers/isdn/icn/icn.c                   |    7 +-
 drivers/net/Kconfig                      |    6 +-
 drivers/net/au1000_eth.c                 |   10 ++--
 drivers/net/cxgb4vf/cxgb4vf_main.c       |   73 ++++++++++++++---------
 drivers/net/cxgb4vf/t4vf_hw.c            |   96 +++++++++++++++++++-----------
 drivers/net/ehea/ehea_main.c             |   18 ++++-
 drivers/net/pch_gbe/pch_gbe_main.c       |    6 +-
 drivers/net/pch_gbe/pch_gbe_param.c      |    8 +-
 drivers/net/ppp_generic.c                |   43 +++++++-------
 drivers/net/ucc_geth.h                   |    3 +-
 drivers/net/usb/hso.c                    |   10 ++-
 drivers/net/wan/x25_asy.c                |   11 ++--
 drivers/net/wireless/ath/ath9k/recv.c    |    2 +-
 drivers/net/wireless/ath/carl9170/main.c |    2 +-
 drivers/net/wireless/b43/sdio.c          |    1 +
 drivers/ssb/b43_pci_bridge.c             |    1 +
 drivers/vhost/net.c                      |    5 +-
 include/linux/pci_ids.h                  |    1 +
 include/net/af_unix.h                    |    2 +
 net/ceph/Makefile                        |   22 -------
 net/dccp/input.c                         |    3 +-
 net/decnet/af_decnet.c                   |    2 +
 net/econet/af_econet.c                   |   91 +++++++++++++---------------
 net/ipv4/inet_hashtables.c               |    3 +-
 net/ipv4/sysctl_net_ipv4.c               |    6 ++-
 net/ipv4/tcp.c                           |    2 +-
 net/ipv4/tcp_ipv4.c                      |    4 +-
 net/unix/af_unix.c                       |   37 ++++++++++--
 net/unix/garbage.c                       |    9 +++-
 30 files changed, 281 insertions(+), 204 deletions(-)
