From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] NET: Fix calculation for collapsed skb size
Date: Mon, 7 Feb 2005 15:27:42 +0100
Message-ID: <20050207142742.GA31837@postel.suug.ch>
References: <20050128230327.GV31837@postel.suug.ch> <E1CufRB-0000zf-00@gondolin.me.apana.org.au> <20050128234828.GA24868@yakov.inr.ac.ru> <20050129002128.GX31837@postel.suug.ch> <20050129002701.GY31837@postel.suug.ch> <20050206223239.5dc4e325.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, herbert@gondor.apana.org.au, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050206223239.5dc4e325.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

patch also applies to 2.4 with some fuzz.

Noticed by Denis V. Lunev <den@asplinux.ru>

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.11-rc3-bk3.orig/net/ipv4/tcp_input.c	2005-02-07 09:47:02.000000000 -0500
+++ linux-2.6.11-rc3-bk3/net/ipv4/tcp_input.c	2005-02-07 09:50:20.000000000 -0500
@@ -3760,8 +3760,7 @@
 	while (before(start, end)) {
 		struct sk_buff *nskb;
 		int header = skb_headroom(skb);
-		int copy = (PAGE_SIZE - sizeof(struct sk_buff) -
-			    sizeof(struct skb_shared_info) - header - 31)&~15;
+		int copy = SKB_MAX_ORDER(header, 0);
 
 		/* Too big header? This can happen with IPv6. */
 		if (copy < 0)
