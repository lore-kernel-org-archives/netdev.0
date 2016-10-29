From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH net-next] firewire: net: really fix maximum possible MTU
Date: Sat, 29 Oct 2016 22:16:58 +0200
Message-ID: <20161029221658.03942ff6@kant>
References: <20161019023333.15760-1-jarod@redhat.com>
        <20161020175524.6184-1-jarod@redhat.com>
        <20161020175524.6184-8-jarod@redhat.com>
        <20161022211606.3b5d137d@kant>
        <20161022212759.228c7642@kant>
        <20161023011824.GE32569@redhat.com>
        <20161023162903.4166a35d@kant>
        <20161023163056.6bc38610@kant>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
        Jarod Wilson <jarod@redhat.com>, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:41349 "EHLO
        einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752794AbcJ2URT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 16:17:19 -0400
In-Reply-To: <20161023163056.6bc38610@kant>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The maximum unicast datagram size /without/ link fragmentation is
4096 - 4 = 4092 (max IEEE 1394 async payload size at >= S800 bus speed,
minus unfragmented encapssulation header).  Max broadcast datagram size
without fragmentation is 8 bytes less than that (due to GASP header).

The maximum datagram size /with/ link fragmentation is 0xfff = 4095
for unicast and broadcast.  This is because the RFC 2734 fragment
encapsulation header field for datagram size is only 12 bits wide.

Fixes: 5d48f00d836a('firewire: net: fix maximum possible MTU')
Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
---
 drivers/firewire/net.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index 03715e7d9d92..363fc5ec1a4e 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -1465,7 +1465,7 @@ static int fwnet_probe(struct fw_unit *unit,
 
 	net->mtu = 1500U;
 	net->min_mtu = ETH_MIN_MTU;
-	net->max_mtu = ETH_MAX_MTU;
+	net->max_mtu = 0xfff;
 
 	/* Set our hardware address while we're at it */
 	ha = (union fwnet_hwaddr *)net->dev_addr;
-- 
Stefan Richter
-======----- =-=- ===-=
http://arcgraph.de/sr/
