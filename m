From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next v2 0/4] bridge: vlan: cleanups & fixes
	(part 3)
Date: Mon, 12 Oct 2015 21:47:01 +0200
Message-ID: <1444679225-7354-1-git-send-email-razor@blackwall.org>
Cc: idosch@mellanox.com, shm@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	roopa@cumulusnetworks.com, bridge@lists.linux-foundation.org,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Hi,
Patch 01 converts the vlgrp member to use rcu as it was already used in a
similar way so better to make it official and use all the available RCU
instrumentation. Patch 02 fixes a bug where the vlan_list can be traversed
without rtnl or rcu held which could lead to using freed entries.
Patch 03 removes some redundant code that isn't needed anymore.
Patch 04 fixes a bug reported by Ido Schimmel about the vlan_flush order
and switchdevs, it moves it back.

v2: patch 03 and 04 are new, couldn't escape the second synchronize_rcu()
since the rhtable destruction can sleep

Thank you,
 Nik

Nikolay Aleksandrov (4):
  bridge: vlan: use proper rcu for the vlgrp member
  bridge: vlan: use rcu for vlan_list traversal in br_fill_ifinfo
  bridge: vlan: drop unnecessary flush code
  bridge: vlan: move back vlan_flush

 net/bridge/br_device.c  |   2 +-
 net/bridge/br_forward.c |   6 +--
 net/bridge/br_if.c      |   3 +-
 net/bridge/br_input.c   |   4 +-
 net/bridge/br_netlink.c |  25 +++++----
 net/bridge/br_private.h |  33 ++++++++++--
 net/bridge/br_vlan.c    | 133 ++++++++++++++++++++++++++++++------------------
 7 files changed, 135 insertions(+), 71 deletions(-)

-- 
2.4.3
