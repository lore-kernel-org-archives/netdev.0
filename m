From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] NETLINK: Use SKB_MAXORDER to calculate NLMSG_GOODSIZE
Date: Sat, 29 Jan 2005 02:48:28 +0300
Message-ID: <20050128234828.GA24868@yakov.inr.ac.ru>
References: <20050128230327.GV31837@postel.suug.ch> <E1CufRB-0000zf-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1CufRB-0000zf-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> > -#define NLMSG_GOODSIZE (PAGE_SIZE - ((sizeof(struct sk_buff)+0xF)&~0xF))


... which reminded me about an old stale patchlet:


Comment: improper size calculation for collapsed skb size.
         Noticed by Denis V. Lunev <den@asplinux.ru>

===== net/ipv4/tcp_input.c 1.89 vs edited =====
--- 1.89/net/ipv4/tcp_input.c	Tue Jan 18 01:09:33 2005
+++ edited/net/ipv4/tcp_input.c	Thu Jan 27 19:41:07 2005
@@ -3760,8 +3760,8 @@
 	while (before(start, end)) {
 		struct sk_buff *nskb;
 		int header = skb_headroom(skb);
-		int copy = (PAGE_SIZE - sizeof(struct sk_buff) -
-			    sizeof(struct skb_shared_info) - header - 31)&~15;
+		int copy = (PAGE_SIZE - sizeof(struct skb_shared_info)
+			    - header - 31)&~15;
 
 		/* Too big header? This can happen with IPv6. */
 		if (copy < 0)
