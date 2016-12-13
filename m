From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next 18/27] net/skbuff: add macros for VLAN_PRESENT bit
Date: Tue, 13 Dec 2016 01:12:38 +0100 (CET)
Message-ID: <3cad1213a287755f5b6d698b45d839ca76d6d841.1481586602.git.mirq-linux@rere.qmqm.pl>
References: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Russell King <linux@armlinux.org.uk> (maintainer:ARM PORT),
        linux-arm-kernel@lists.infradead.org (moderated list:ARM PORT),
        Ralf Baechle <ralf@linux-mips.org> (supporter:MIPS),
        linux-mips@linux-mips.org (open list:MIPS),
        Benjamin Herrenschmidt <benh@kernel.crashing.org> (supporter:LINUX
        FOR POWERPC (32-BIT AND 64-BIT)),
        Paul Mackerras <paulus@samba.org> (supporter:LINUX FOR POWERPC
        (32-BIT AND 64-BIT)),
        Michael Ellerman <mpe@ellerman.id.au> (supporter:LINUX FOR POWERPC
        (32-BIT AND 64-BIT),commit_signer:2/5=40%),
        linuxppc-dev@lists.ozlabs.org (open list:LINUX FOR POWERPC (32-BIT AND
        64-BIT)),
        "David S. Miller" <davem@davemloft.net> (maintainer:SPARC + UltraSPARC
        (sparc/sparc64),commit_signer:2/4=50%),
        sparclinux@vger.kernel.org (open list:SPARC + UltraSPARC
        (sparc/sp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:50220 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932591AbcLMAMm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 19:12:42 -0500
In-Reply-To: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 include/linux/skbuff.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 332e767..4a85a1f 100644
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
2.10.2
