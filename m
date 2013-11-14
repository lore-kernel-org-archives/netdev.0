From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net v2 0/2] macvlan: disable LRO on lowerdev instead of a macvlan
Date: Thu, 14 Nov 2013 15:00:06 +0100 (CET)
Message-ID: <cover.1384436410.git.mkubecek@suse.cz>
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	John Fastabend <john.r.fastabend@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:53403 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752466Ab3KNOAI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Nov 2013 09:00:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A customer of ours encountered a problem with LRO on an ixgbe network
card. Analysis showed that it was a known conflict of forwarding and LRO
but the forwarding was enabled in an LXC container where only a macvlan
was, not the ethernet device itself.

I believe the solution is exactly the same as what we do for "normal"
(802.1q) VLAN devices: if dev_disable_lro() is called for such device,
LRO is disabled on the underlying "real" device instead.

v2: adapt to changes merged from net-next

Michal Kubecek (2):
  macvlan: introduce macvlan_dev_real_dev() helper function
  macvlan: disable LRO on lower device instead of macvlan

 include/linux/if_macvlan.h | 16 ++++++++++++++++
 net/core/dev.c             |  5 +++++
 2 files changed, 21 insertions(+)

-- 
1.8.1.4
