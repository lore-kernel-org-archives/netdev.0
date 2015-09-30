From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 0/5] bridge: vlan: cleanups & fixes
Date: Wed, 30 Sep 2015 20:16:50 +0200
Message-ID: <1443637015-4153-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, vyasevich@gmail.com,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:34759 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933080AbbI3SRB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 14:17:01 -0400
Received: by wicfx3 with SMTP id fx3so210277078wic.1
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 11:17:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Hi,
This is the first follow-up set, patch 01 reduces the default rhashtable
size and the number of locks that can be allocated. Patch 02 and 04 fix
possible null pointer dereferences due to the new ordering and
initialization on port add/del, and patch 03 moves the "pvid" member in
the net_bridge_vlan_group struct in order to simplify code (similar to how
it was with the older struct). Patch 05 fixes adding a vlan on a port which
is pvid and doesn't have a global context yet.
Please review carefully, I think this is the first use of rhashtable's
"locks_mul" member in the tree and I'd like to make sure it's correct.
Another thing that needs special attention is the nbp_vlan_flush() move
after the rx_handler unregister.

Cheers,
 Nik


Nikolay Aleksandrov (5):
  bridge: vlan: adjust rhashtable initial size and hash locks size
  bridge: vlan: fix possible null vlgrp deref while registering new port
  bridge: vlan: move pvid inside net_bridge_vlan_group
  bridge: vlan: fix possible null ptr derefs on port init and deinit
  bridge: vlan: don't pass flags when creating context only

 net/bridge/br_device.c  |   2 +-
 net/bridge/br_if.c      |   3 +-
 net/bridge/br_input.c   |   2 +-
 net/bridge/br_netlink.c |  42 +++++++---------
 net/bridge/br_private.h |  44 +++++------------
 net/bridge/br_vlan.c    | 127 ++++++++++++++++++++++--------------------------
 6 files changed, 93 insertions(+), 127 deletions(-)

-- 
2.4.3
