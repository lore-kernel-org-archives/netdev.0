From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/5] ieee802154: document the skb->cb
	usage clearly.
Date: Thu, 20 Aug 2009 20:13:03 +0400
Message-ID: <1250784787-30590-2-git-send-email-dbaryshkov@gmail.com>
References: <1250784787-30590-1-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1250784787-30590-1-git-send-email-dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 Documentation/networking/ieee802154.txt |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/ieee802154.txt b/Documentation/networking/ieee802154.txt
index 1c0c82c..23c995e 100644
--- a/Documentation/networking/ieee802154.txt
+++ b/Documentation/networking/ieee802154.txt
@@ -56,8 +56,12 @@ HardMAC
 
 See the header include/net/ieee802154_netdev.h. You have to implement Linux
 net_device, with .type = ARPHRD_IEEE802154. Data is exchanged with socket family
-code via plain sk_buffs. The control block of sk_buffs will contain additional
-info as described in the struct ieee802154_mac_cb.
+code via plain sk_buffs. On skb reception skb->cb must contain additional
+info as described in the struct ieee802154_mac_cb. During packet transmission
+the skb->cb is used to provide additional data to device's header_ops->create
+function. Be aware, that this data can be overriden later (when socket code
+submits skb to qdisc), so if you need something from that cb later, you should
+store info in the skb->data on your own.
 
 To hook the MLME interface you have to populate the ml_priv field of your
 net_device with a pointer to struct ieee802154_mlme_ops instance. All fields are
@@ -73,3 +77,4 @@ We are going to provide intermediate layer implementing IEEE 802.15.4 MAC
 in software. This is currently WIP.
 
 See header include/net/mac802154.h and several drivers in drivers/ieee802154/.
+
-- 
1.6.3.3


------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with 
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
