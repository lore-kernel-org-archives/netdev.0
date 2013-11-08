From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net 0/2] macvlan: disable LRO on lowerdev instead of a macvlan
Date: Fri,  8 Nov 2013 14:40:54 +0100 (CET)
Message-ID: <cover.1383915401.git.mkubecek@suse.cz>
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:45937 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751118Ab3KHNkz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Nov 2013 08:40:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A customer of ours encountered a problem with LRO on an ixgbe network
card. Analysis showed that it was a known conflict of forwarding and LRO
but the forwarding was enabled in an LXC container where only a macvlan
was, not the ethernet device itself.

I believe the solution is exactly the same as what we do for "normal"
(802.1q) VLAN devices: if dev_disable_lro() is called for such device,
LRO is disabled on the underlying "real" device instead.

Michal Kubecek (2):
  macvlan: introduce IFF_MACVLAN flag and helper functions
  macvlan: disable LRO on lower device instead of macvlan

 drivers/net/macvlan.c      |  2 +-
 include/linux/if_macvlan.h | 26 ++++++++++++++++++++++++++
 include/uapi/linux/if.h    |  1 +
 net/core/dev.c             |  5 +++++
 4 files changed, 33 insertions(+), 1 deletion(-)

-- 
1.8.1.4
