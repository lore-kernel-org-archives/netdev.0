From: Patrick McHardy <kaber@trash.net>
Subject: Re: CONFIG_NETFILTER_DEBUG spew
Date: Mon, 02 May 2005 18:12:47 +0200
Message-ID: <4276517F.6030606@trash.net>
References: <20050501032809.3d0b4cda.akpm@osdl.org>
	<20050501111507.GA2133@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070605040806010003070303"
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com,
	netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050501111507.GA2133@gondor.apana.org.au>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070605040806010003070303
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:
> BTW, should we do nf_reset in ip_dev_loopback_xmit as well?

I think we should, tc actions could do something unexpected with
the packet.

Regards
Patrick

--------------070605040806010003070303
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NETFILTER]: Drop conntrack reference in ip_dev_loopback_xmit()

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit c4644e58c8b52dca9699e8ee0e975f5f13eb4d2c
tree 35d8915a3fd6fa39a46d9b2e8e1fd272e82ea3af
parent a91b6fa8bc4b1626d413d58c21cfcfecabbb4a61
author Patrick McHardy <kaber@trash.net> 1115049922 +0200
committer Patrick McHardy <kaber@trash.net> 1115049922 +0200

Index: net/core/netfilter.c
===================================================================
--- 9544bb88b28c2e3ca4b0a66fedfa2bb540ec06e2/net/core/netfilter.c  (mode:100644 sha1:92c51824797dd15018e579eb5753cc372e04fd3d)
+++ 35d8915a3fd6fa39a46d9b2e8e1fd272e82ea3af/net/core/netfilter.c  (mode:100644 sha1:22a8f127c4aad9821e5f3294aa518807165ee8b7)
@@ -236,8 +236,6 @@
 		debug_print_hooks_ip(newskb->nf_debug);
 		nf_dump_skb(PF_INET, newskb);
 	}
-	/* Clear to avoid confusing input check */
-	newskb->nf_debug = 0;
 }
 
 void nf_debug_ip_finish_output2(struct sk_buff *skb)
Index: net/ipv4/ip_output.c
===================================================================
--- 9544bb88b28c2e3ca4b0a66fedfa2bb540ec06e2/net/ipv4/ip_output.c  (mode:100644 sha1:38f69532a029e5ff1ddbdbd665afcff46e94abb5)
+++ 35d8915a3fd6fa39a46d9b2e8e1fd272e82ea3af/net/ipv4/ip_output.c  (mode:100644 sha1:24fe3e00b42b0bb673be5a6d8ceb15defb192974)
@@ -111,6 +111,7 @@
 #ifdef CONFIG_NETFILTER_DEBUG
 	nf_debug_ip_loopback_xmit(newskb);
 #endif
+	nf_reset(newskb);
 	netif_rx(newskb);
 	return 0;
 }

--------------070605040806010003070303--
