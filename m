From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net v3 0/2] macvlan: disable LRO on lowerdev instead of a macvlan
Date: Fri, 15 Nov 2013 06:18:30 +0100 (CET)
Message-ID: <cover.1384492269.git.mkubecek@suse.cz>
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:52840 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750920Ab3KOFSd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Nov 2013 00:18:33 -0500
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

v3: use BUG() in macvlan_dev_real_dev() if compiled without macvlan

Michal Kubecek (2):
  macvlan: introduce macvlan_dev_real_dev() helper function
  macvlan: disable LRO on lower device instead of macvlan

 include/linux/if_macvlan.h | 17 +++++++++++++++++
 net/core/dev.c             |  5 +++++
 2 files changed, 22 insertions(+)

-- 
1.8.1.4
