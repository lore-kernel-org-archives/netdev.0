From: Arvid Brodin <arvid.brodin@alten.se>
Subject: [PATCH net-next] net/hsr: Remove left-over never-true conditional
 code.
Date: Fri, 11 Jul 2014 18:21:12 +0200
Message-ID: <53C00EF8.1040403@alten.se>
References: <20140710210037.GA14669@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
	<kernel-janitors@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20140710210037.GA14669@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

MacAddressB is an array (unsigned char MacAddressB[ETH_ALEN]) and is al=
located
as a part of *node_dst (which is a struct hsr_node). So the condition i=
s always
false.

Detected by Dan Carpenter.

Signed-off-by: Arvid Brodin <arvid.brodin@alten.se>
---
 net/hsr/hsr_framereg.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/hsr/hsr_framereg.c b/net/hsr/hsr_framereg.c
index c709c13..bace124 100644
--- a/net/hsr/hsr_framereg.c
+++ b/net/hsr/hsr_framereg.c
@@ -290,10 +290,6 @@ void hsr_addr_subst_dest(struct hsr_node *node_src=
, struct sk_buff *skb,
 	}
 	if (port->type !=3D node_dst->AddrB_port)
 		return;
-	if (!node_dst->MacAddressB) {
-		WARN_ONCE(1, "%s: No MacAddressB\n", __func__);
-		return;
-	}
=20
 	ether_addr_copy(eth_hdr(skb)->h_dest, node_dst->MacAddressB);
 }
--=20
1.8.3.2

--=20
Arvid Brodin | Consultant (Linux)
ALTEN | Knarrarn=E4sgatan 7 | SE-164 40 Kista | Sweden
arvid.brodin@alten.se | www.alten.se/en/
--
To unsubscribe from this list: send the line "unsubscribe kernel-janito=
rs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
