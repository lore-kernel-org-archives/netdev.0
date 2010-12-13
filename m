From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 0/3] bonding fixes
Date: Mon, 13 Dec 2010 18:16:56 +0000
Message-ID: <1292264216.9860.11.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>, Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:34958 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753458Ab0LMSRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 13:17:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been investigating a bonding bug that results in skb_under_panic()
on older kernels.  The bug is still present but with less disastrous
results.  In the course of my investigation I found two regressions
without actually looking very hard, which is somewhat worrying.

The fixes are:

1. Remove redundant VLAN tag insertion logic. Fixes a regression due to
VLAN handling changes in 2.6.37, which corrupts *all* outgoing traffic
on a VLAN over a bond when the slave does not implement VLAN tag
insertion.

2. Change active slave quietly when bond is down. Fixes a crash
introduced by 5a37e8ca8536c47871d46c82211f399adf06fd44 (bonding: rejoin
multicast groups on VLANs) and also cleans up existing code.

3. Fix mangled NAs on slaves without VLAN tag insertion. This bug
appears to have been present ever since gratuitous NAs were implemented
in 2.6.29. It doesn't look possible to fix without relying on the recent
VLAN handling changes. For stable/longterm and backports, I think the
safest thing to do is not to send a gratuitous NA if it would end up
mangled.

Ben.

Ben Hutchings (3):
  bonding/vlan: Remove redundant VLAN tag insertion logic
  bonding: Change active slave quietly when bond is down
  bonding/vlan: Fix mangled NAs on slaves without VLAN tag insertion

 drivers/net/bonding/bond_ipv6.c |    7 +++++-
 drivers/net/bonding/bond_main.c |   42 +++++++++-----------------------------
 2 files changed, 16 insertions(+), 33 deletions(-)

-- 
1.7.3.2


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

