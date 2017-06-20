From: John Crispin <john@phrozen.org>
Subject: [RFC 2/2] net-next: mt7530: add nh and proto offsets to the ops struct
Date: Tue, 20 Jun 2017 10:06:55 +0200
Message-ID: <20170620080655.7251-2-john@phrozen.org>
References: <20170620080655.7251-1-john@phrozen.org>
Cc: netdev@vger.kernel.org, John Crispin <john@phrozen.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:45220 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752085AbdFTIHV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Jun 2017 04:07:21 -0400
In-Reply-To: <20170620080655.7251-1-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MT7530 inserts the 4 magic header in between the 802.3 address and
protocol field. The patch defines these header such that the flow_disector
can properly parse the packet and thus allows hashing to function properly.

Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/dsa/mt7530.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/dsa/mt7530.c b/drivers/net/dsa/mt7530.c
index 1e46418a3b74..b5385e554601 100644
--- a/drivers/net/dsa/mt7530.c
+++ b/drivers/net/dsa/mt7530.c
@@ -1019,6 +1019,8 @@ static struct dsa_switch_ops mt7530_switch_ops = {
 	.port_fdb_add		= mt7530_port_fdb_add,
 	.port_fdb_del		= mt7530_port_fdb_del,
 	.port_fdb_dump		= mt7530_port_fdb_dump,
+	.hash_nh_off		= 4,
+	.hash_nh_proto		= 2,
 };
 
 static int
-- 
2.11.0
