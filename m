From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 0/3] bonding,ipv4,ipv6,vlan: Use notifiers to
 trigger advertisements on failover
Date: Sat, 16 Apr 2011 00:41:01 +0100
Message-ID: <1302910861.2845.36.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ian Campbell <Ian.Campbell@citrix.com>
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:6485 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751344Ab1DOXlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 19:41:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is undesirable for the bonding driver to be poking into higher
level protocols, and notifiers provide a way to avoid that.

Ian added NETDEV_NOTIFY_PEERS to trigger gratuitous ARP on VM migration.
We should extend that to unsolicited NAs and propagate it through VLANs,
then treat bonding failover in the same way.

Ben.

Ben Hutchings (3):
  ipv6: Send unsolicited neighbour advertisements when notified
  vlan: Propagate NETDEV_NOTIFY_PEERS notifier
  bonding,ipv4,ipv6,vlan: Handle NETDEV_BONDING_FAILOVER like
    NETDEV_NOTIFY_PEERS

 drivers/net/bonding/Makefile     |    3 -
 drivers/net/bonding/bond_ipv6.c  |  225 --------------------------------------
 drivers/net/bonding/bond_main.c  |   96 ----------------
 drivers/net/bonding/bond_sysfs.c |   80 --------------
 drivers/net/bonding/bonding.h    |   29 -----
 net/8021q/vlan.c                 |   12 ++
 net/ipv4/devinet.c               |    1 +
 net/ipv6/ndisc.c                 |   27 +++++
 8 files changed, 40 insertions(+), 433 deletions(-)
 delete mode 100644 drivers/net/bonding/bond_ipv6.c

-- 
1.7.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

