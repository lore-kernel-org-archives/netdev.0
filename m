From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCHv2] netfilter: Remove skb_is_nonlinear check from	nf_conntrack_sip
Date: Fri, 14 May 2010 20:13:03 +0200
Message-ID: <4BED92AF.50704@trash.net>
References: <20100514180138.GF15969@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040804060400000405070906"
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100514180138.GF15969@obsidianresearch.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040804060400000405070906
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Jason Gunthorpe wrote:
> At least the XEN net front driver always produces non linear skbs,
> so the SIP module does nothing at all when used with that NIC.
> 
> Unconditionally linearize the skb..
> 
> Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> ---
>  net/netfilter/nf_conntrack_sip.c |    9 +++------
>  1 files changed, 3 insertions(+), 6 deletions(-)
> 
> Patrick/Jan, thanks.. This is what I wanted to do in the first place,
> but I couldn't convince myself it was safe, as no other nf code does
> this..

Your patch is based on an old version, the current version also
supports TCP. I'll commit this patch to my tree after some testing.

--------------040804060400000405070906
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index b20f427..45750cc 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -1393,10 +1393,8 @@ static int sip_help_tcp(struct sk_buff *skb, unsigned int protoff,
 
 	nf_ct_refresh(ct, skb, sip_timeout * HZ);
 
-	if (skb_is_nonlinear(skb)) {
-		pr_debug("Copy of skbuff not supported yet.\n");
+	if (unlikely(skb_linearize(skb)))
 		return NF_ACCEPT;
-	}
 
 	dptr = skb->data + dataoff;
 	datalen = skb->len - dataoff;
@@ -1455,10 +1453,8 @@ static int sip_help_udp(struct sk_buff *skb, unsigned int protoff,
 
 	nf_ct_refresh(ct, skb, sip_timeout * HZ);
 
-	if (skb_is_nonlinear(skb)) {
-		pr_debug("Copy of skbuff not supported yet.\n");
+	if (unlikely(skb_linearize(skb)))
 		return NF_ACCEPT;
-	}
 
 	dptr = skb->data + dataoff;
 	datalen = skb->len - dataoff;

--------------040804060400000405070906--
