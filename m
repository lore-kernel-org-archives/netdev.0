From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 0/4] bridge: vlan: cleanups & fixes (part
	3)
Date: Mon, 12 Oct 2015 13:41:05 +0200
Message-ID: <1444650069-32572-1-git-send-email-razor@blackwall.org>
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
I'm not intializing vlgrp to null before kfree_rcu because Ido has a patch
for that which fixes a warning from kasan.
Patch 03 fixes a bug reported by Ido Schimmel about the vlan_flush order
and switchdevs, and patch 04 refactors (br|nbp)_vlan_flush and combines
them into a single function.

Thank you,
 Nik

Nikolay Aleksandrov (4):
  bridge: vlan: use proper rcu for the vlgrp member
  bridge: vlan: use rcu for vlan_list traversal in br_fill_ifinfo
  bridge: vlan: break vlan_flush in two phases to keep old order
  bridge: vlan: combine (br|nbp)_vlan_flush into one

 net/bridge/br_device.c  |   2 +-
 net/bridge/br_forward.c |   6 +--
 net/bridge/br_if.c      |  13 +++--
 net/bridge/br_input.c   |   4 +-
 net/bridge/br_netlink.c |  25 ++++++----
 net/bridge/br_private.h |  43 ++++++++++++-----
 net/bridge/br_vlan.c    | 124 +++++++++++++++++++++++++++---------------------
 7 files changed, 132 insertions(+), 85 deletions(-)

-- 
2.4.3
