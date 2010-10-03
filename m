From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sun, 03 Oct 2010 11:41:13 -0700 (PDT)
Message-ID: <20101003.114113.193724410.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) The UM duplicate field regression fix, from Boaz Harrosh.

2) Max SYN retry sysctl doesn't end up generating the right number of
   SYN retransmits due to bad calculations in retransmits_timed_out().
   Fix from Damian Lukowski.

3) We erroneously drop VLAN packets when device is in promiscuous mode,
   fix from Eric Dumazet.

4) Fix ip_gre Kconfig dependenices wrt. ipv6.

5) Phone uses stale protocol header pointer after pskb_may_pull() call,
   fix from Kumar Sanghvi.

6) Use after free fix in mac80211 from Johannes Berg.

7) Fix work queueing in Intel wireless, from Florian Mickler.

Please pull, thanks a lot!

The following changes since commit c6ea21e35bf3691cad59647c771e6606067f627d:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/sfrench/cifs-2.6 (2010-10-01 15:03:37 -0700)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Boaz Harrosh (1):
      um: Proper Fix for f25c80a4: remove duplicate structure field initialization

Damian Lukowski (1):
      net-2.6: SYN retransmits: Add new parameter to retransmits_timed_out()

David S. Miller (2):
      ip_gre: Fix dependencies wrt. ipv6.
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6

Eric Dumazet (1):
      vlan: dont drop packets from unknown vlans in promiscuous mode

Florian Mickler (1):
      iwl3945: queue the right work if the scan needs to be aborted

Johannes Berg (1):
      mac80211: fix use-after-free

Kumar Sanghvi (1):
      Phonet: Correct header retrieval after pskb_may_pull

 arch/um/drivers/net_kern.c                  |   17 +++--------------
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c  |    2 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    2 +-
 net/8021q/vlan_core.c                       |   14 ++++++++++----
 net/ipv4/Kconfig                            |    1 +
 net/ipv4/tcp_timer.c                        |   24 ++++++++++++++----------
 net/mac80211/rx.c                           |    4 ----
 net/phonet/pep.c                            |    3 ++-
 8 files changed, 32 insertions(+), 35 deletions(-)
