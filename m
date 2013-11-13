From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net 0/3] bridge: Fix undesirable behavior related to vlan
Date: Wed, 13 Nov 2013 17:26:11 +0900
Message-ID: <1384331175-4136-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:47787 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758268Ab3KMI2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 03:28:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There seem to be some problems around vlan code.

- Unexpectedly filter vlan by NIC.
- Not correctly decrement refcount of vlan_vid_info.
- Memory leak when deleting a bridge with vlan_info allocated.

This is a patch series to fix these issues.

Toshiaki Makita (3):
  bridge: Use vlan_vid_[add/del] instead of direct
    ndo_vlan_rx_[add/kill]_vid calls
  bridge: Call vlan_vid_del for all vids at nbp_vlan_flush
  bridge: Fix memory leak when deleting bridge with vlan filtering
    enabled

 net/bridge/br_if.c   |  1 +
 net/bridge/br_vlan.c | 24 ++++++++++--------------
 2 files changed, 11 insertions(+), 14 deletions(-)

-- 
1.8.1.2
