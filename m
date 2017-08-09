From: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
Subject: [PATCH 2/4] net-next: dsa: add flow_dissect callback to struct
 dsa_device_ops
Date: Wed,  9 Aug 2017 14:41:17 +0200
Message-ID: <20170809124119.24320-3-john@phrozen.org>
References: <20170809124119.24320-1-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Muciri Gatimu <muciri-lv6y7wLVQPlWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Shashidhar Lakkavalli <shashidhar.lakkavalli-lv6y7wLVQPlWk0Htik3J/w@public.gmane.org>,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
 Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>,
 Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20170809124119.24320-1-john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

When the flow dissector first sees packets coming in on a DSA devices the
802.3 header wont be located where the code expects it to be as the tag
is still present. Adding this new callback allows a DSA device to provide a
new function that the flow_dissector can use to get the correct protocol
and offset of the network header.

Signed-off-by: Muciri Gatimu <muciri-lv6y7wLVQPlWk0Htik3J/w@public.gmane.org>
Signed-off-by: Shashidhar Lakkavalli <shashidhar.lakkavalli-lv6y7wLVQPlWk0Htik3J/w@public.gmane.org>
Signed-off-by: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
---
 include/net/dsa.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 65d7804c6f69..7f46b521313e 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -106,6 +106,8 @@ struct dsa_device_ops {
 	struct sk_buff *(*rcv)(struct sk_buff *skb, struct net_device *dev,
 			       struct packet_type *pt,
 			       struct net_device *orig_dev);
+	int (*flow_dissect)(const struct sk_buff *skb, __be16 *proto,
+			    int *offset);
 };
 
 struct dsa_switch_tree {
-- 
2.11.0
