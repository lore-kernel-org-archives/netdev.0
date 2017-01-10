From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 5/8] net: dsa: Export dev_to_net_device()
Date: Tue, 10 Jan 2017 12:12:32 -0800
Message-ID: <20170110201235.21771-6-f.fainelli@gmail.com>
References: <20170110201235.21771-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Florian Fainelli <f.fainelli@gmail.com>,
 Ingo Tuchscherer <ingo.tuchscherer@linux.vnet.ibm.com>,
 Jason Cooper <jason@lakedaemon.net>,
 Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 open list <linux-kernel@vger.kernel.org>, Russell King <linux@armlinux.org.uk>,
 Stuart Yoder <stuart.yoder@nxp.com>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Philippe Reynes <tremyfr@gmail.com>, "David S. Miller" <davem@davemloft.net>,
 "moderated list:ARM/Marvell Dove/MV78xx0/Orion SOC support"
 <linux-arm-kernel@lists.infradead.org>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170110201235.21771-1-f.fainelli@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

We are going to need this in net/dsa/dsa2.c as well, so make it
avaialable.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h | 1 +
 net/dsa/dsa.c     | 3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 16a502a6c26a..b9394379affb 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -396,6 +396,7 @@ struct dsa_switch_driver {
 void register_switch_driver(struct dsa_switch_driver *type);
 void unregister_switch_driver(struct dsa_switch_driver *type);
 struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev);
+struct net_device *dev_to_net_device(struct device *dev);
 
 static inline bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst)
 {
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 2306d1b87c83..691ffc3f8ee6 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -491,7 +491,7 @@ struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev)
 }
 EXPORT_SYMBOL_GPL(dsa_host_dev_to_mii_bus);
 
-static struct net_device *dev_to_net_device(struct device *dev)
+struct net_device *dev_to_net_device(struct device *dev)
 {
 	struct device *d;
 
@@ -508,6 +508,7 @@ static struct net_device *dev_to_net_device(struct device *dev)
 
 	return NULL;
 }
+EXPORT_SYMBOL_GPL(dev_to_net_device);
 
 #ifdef CONFIG_OF
 static int dsa_of_setup_routing_table(struct dsa_platform_data *pd,
-- 
2.9.3
