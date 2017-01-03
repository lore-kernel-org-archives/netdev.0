From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next v2 18/27] net/skbuff: add macros for VLAN_PRESENT bit
Date: Tue,  3 Jan 2017 21:52:38 +0100 (CET)
Message-ID: <719ecd1e2cb20316daf110de4dc865593c7bed9d.1483475202.git.mirq-linux@rere.qmqm.pl>
References: <cover.1483475202.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Russell King <linux@armlinux.org.uk>,
        Ralf Baechle <ralf@linux-mips.org>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Michael Ellerman <mpe@ellerman.id.au>,
        "David S. Miller" <davem@davemloft.net>,
        linux-arm-kernel@lists.infradead.org, linux-mips@linux-mips.org,
        linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <cover.1483475202.git.mirq-linux@rere.qmqm.pl>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 include/linux/skbuff.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index b53c0cfd417e..168c3e486bd4 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -768,6 +768,12 @@ struct sk_buff {
 	__u32			priority;
 	int			skb_iif;
 	__u32			hash;
+#define PKT_VLAN_PRESENT_BIT	4	// CFI (12-th bit) in TCI
+#ifdef __BIG_ENDIAN
+#define PKT_VLAN_PRESENT_OFFSET()	offsetof(struct sk_buff, vlan_tci)
+#else
+#define PKT_VLAN_PRESENT_OFFSET()	(offsetof(struct sk_buff, vlan_tci) + 1)
+#endif
 	__be16			vlan_proto;
 	__u16			vlan_tci;
 #if defined(CONFIG_NET_RX_BUSY_POLL) || defined(CONFIG_XPS)
-- 
2.11.0
