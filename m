From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCHv2 net 0/3] Prevent extreme TSO parameters from stalling TX
 queues
Date: Tue, 31 Jul 2012 02:51:16 +0100
Message-ID: <1343699476.2667.69.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Ben Greear <greearb@candelatech.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:46034 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753725Ab2GaBvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 21:51:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes fix a potential DoS by peers or local users on
network interfaces using the sfc driver (and possibly others) with TSO
enabled (as it is by default).

Please apply patches 1 and 2 to the net tree and your stable update
queue.  I'm not sure whether patch 3 is really important.

Ben.

Ben Hutchings (3):
  net: Allow driver to limit number of GSO segments per skb
  sfc: Fix maximum number of TSO segments and minimum TX queue size
  tcp: Apply device TSO segment limit earlier

 drivers/net/ethernet/sfc/efx.c     |    6 ++++++
 drivers/net/ethernet/sfc/efx.h     |   14 ++++++++++----
 drivers/net/ethernet/sfc/ethtool.c |   16 +++++++++++-----
 drivers/net/ethernet/sfc/tx.c      |   19 +++++++++++++++++++
 include/linux/netdevice.h          |    2 ++
 include/net/sock.h                 |    2 ++
 net/core/dev.c                     |    4 ++++
 net/core/sock.c                    |    1 +
 net/ipv4/tcp.c                     |    4 +++-
 net/ipv4/tcp_cong.c                |    3 ++-
 net/ipv4/tcp_output.c              |   21 ++++++++++++---------
 11 files changed, 72 insertions(+), 20 deletions(-)

-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
