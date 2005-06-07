From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 5/9]: TCP: The Road to Super TSO
Date: Mon, 06 Jun 2005 21:19:46 -0700 (PDT)
Message-ID: <20050606.211946.21590576.davem@davemloft.net>
References: <20050606.210846.07641049.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jheffner@psc.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050606.210846.07641049.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


[TCP]: Add missing skb_header_release() call to tcp_fragment().

When we add any new packet to the TCP socket write queue,
we must call skb_header_release() on it in order for the
TSO sharing checks in the drivers to work.

Signed-off-by: David S. Miller <davem@davemloft.net>

79eb6b25499ed5470cb7b20428c435288fcb3502 (from bdbf09522de5be3ada129dceaa3ad9da9be078bc)
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -660,6 +660,7 @@ static int tcp_fragment(struct sock *sk,
 	}
 
 	/* Link BUFF into the send queue. */
+	skb_header_release(buff);
 	__skb_append(skb, buff);
 
 	return 0;
