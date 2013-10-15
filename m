From: =?iso-8859-15?Q?Kelleter=2C_G=FCnther?= <GKelleter@datus.com>
Subject: [PATCH] X.25: Fix address field length calculation
Date: Tue, 15 Oct 2013 14:29:06 +0000
Message-ID: <525D5131.9070007@datus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"linux-x25@vger.kernel.org" <linux-x25@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "andrew.hendry@gmail.com" <andrew.hendry@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: de-DE
Content-ID: <01736E88829C1B4A9589D66039BC9A5E@datus.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Addresses are BCD encoded, not ASCII. x25_addr_ntoa got it right.

Signed-off-by: Guenther Kelleter <gkelleter@datus.com>
---
Wrong length calculation leads to rejection of CALL ACCEPT packets.

 net/x25/af_x25.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 45a3ab5..2daf224 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -98,7 +98,7 @@ int x25_parse_address_block(struct sk_buff *skb,
 	}
  	len = *skb->data;
-	needed = 1 + (len >> 4) + (len & 0x0f);
+	needed = 1 + ((len >> 4) + (len & 0x0f) + 1) / 2;
  	if (!pskb_may_pull(skb, needed)) {
 		/* packet is too short to hold the addresses it claims
-- 
1.8.3.4.71.g0878476
