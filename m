From: Stephen Hemminger <shemminger@osdl.org>
Subject: pppoe and receive checksum offload
Date: Thu, 24 Feb 2005 15:59:06 -0800
Message-ID: <20050224155906.73890361@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>, mostrows@speakeasy.net,
        Alexey
 Kuznetsov <kuznet@ms2.inr.ac.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Someone reported a problem with skge hardware receive checksumming and PPPOE
but it looks like a generic problem.  Since PPPOE adds additional header
bytes the hardware computed checksum will be wrong.  

Not sure if this is correct, but shouldn't pppoe be doing the following:
-----
diff -Nru a/drivers/net/pppoe.c b/drivers/net/pppoe.c
--- a/drivers/net/pppoe.c	2005-02-24 15:40:10 -08:00
+++ b/drivers/net/pppoe.c	2005-02-24 15:40:10 -08:00
@@ -339,6 +339,7 @@
 		int len = ntohs(ph->length);
 		skb_pull(skb, sizeof(struct pppoe_hdr));
 		skb_trim(skb, len);
+		skb->ip_summed = CHECKSUM_NONE;
 
 		ppp_input(&po->chan, skb);
 	} else if (sk->sk_state & PPPOX_RELAY) {
