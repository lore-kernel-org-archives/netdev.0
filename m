From: Marcelo Abreu <skewer@terra.com.br>
Subject: Re: [PATCH][2.6] fix compilation w/o CONFIG_XFRM
Date: Sat, 18 Oct 2003 23:42:51 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F91FA2B.5050701@terra.com.br>
References: <Pine.LNX.4.53.0310180300500.2831@montezuma.fsmlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <Pine.LNX.4.53.0310180300500.2831@montezuma.fsmlabs.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	In case it's not fixed yet...

	I'm just reusing the patch from Zwane Mwaikambo for sit.c, now to
fix compilation of ip6_tunnel.c.

	Please verify.


--- linux-2.6.0-test8-a/net/ipv6/ip6_tunnel.c     2003-10-18 23:16:42.000000000 -0300
+++ linux-2.6.0-test8-b/net/ipv6/ip6_tunnel.c     2003-10-18 23:17:03.000000000 -0300
@@ -515,8 +515,10 @@
                        read_unlock(&ip6ip6_lock);
                        goto discard;
                }
+#ifdef CONFIG_XFRM
                secpath_put(skb->sp);
                skb->sp = NULL;
+#endif
                skb->mac.raw = skb->nh.raw;
                skb->nh.raw = skb->data;
                skb->protocol = htons(ETH_P_IPV6);
