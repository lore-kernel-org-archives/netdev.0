From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net 0/7] bridge: Fix corner case problems around local fdb entries
Date: Mon,  2 Dec 2013 15:40:31 +0900
Message-ID: <1385966439-26526-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:33624 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752864Ab3LBGl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 01:41:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are so many corner cases that are not handled properly around local
fdb entries.
- We might fail to delete the old entry and might delete an arbitrary local
  entry when changing mac address of a bridge port.
- We always fail to delete the old entry when changing mac address of the
  bridge device.
- We might incorrectly delete a necessary entry when detaching a bridge port.
- We might incorrectly delete a necessary entry when deleting a vlan.
and so on.

This is a patch series to fix these issues.

Toshiaki Makita (7):
  bridge: Fix the way finding the old local fdb entry in
    br_fdb_changeaddr
  bridge: Fix the way finding the old local fdb entry in
    br_fdb_change_mac_address
  bridge: Change local fdb entries whenever mac address of bridge device
    changes
  bridge: Fix the way checking if a local fdb entry can be deleted
  bridge: Properly check if local fdb entry can be deleted in
    br_fdb_change_mac_address
  bridge: Properly check if local fdb entry can be deleted in
    br_fdb_delete_by_port
  bridge: Properly check if local fdb entry can be deleted when deleting
    vlan

 net/bridge/br_device.c  |   3 +-
 net/bridge/br_fdb.c     | 144 ++++++++++++++++++++++--------------------------
 net/bridge/br_if.c      |   1 +
 net/bridge/br_notify.c  |   9 ++-
 net/bridge/br_private.h |  27 ++++++++-
 net/bridge/br_stp_if.c  |   2 +
 net/bridge/br_vlan.c    |  23 +++++++-
 7 files changed, 120 insertions(+), 89 deletions(-)

-- 
1.8.1.2
