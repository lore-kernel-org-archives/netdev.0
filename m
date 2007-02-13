From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.20 crash in tcp_tso_segment()
Date: Wed, 14 Feb 2007 08:51:58 +1100
Message-ID: <20070213215158.GA29814@gondor.apana.org.au>
References: <E1HFc6X-0006n7-00@gondolin.me.apana.org.au> <45D1CC83.8080603@trash.net> <20070213175121.GA27281@gondor.apana.org.au> <20070213.123413.35665346.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, maccetta@laurelnetworks.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4193 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751122AbXBMVwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 16:52:16 -0500
Content-Disposition: inline
In-Reply-To: <20070213.123413.35665346.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 13, 2007 at 12:34:13PM -0800, David Miller wrote:
>
> I'm kind of challenged for time as I'll be out of town from
> Wednesday until Sunday, so if someone could cook up the TSO
> variable of the patch for pre-GSO kernels I'd appreciate it.

Sure, here is the patch for any kernel prior to 2.6.18.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index 0bba3c2..ff396c4 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -148,6 +148,9 @@ static void send_reset(struct sk_buff *oldskb, int hook)
 	nf_reset(nskb);
 	nskb->nfmark = 0;
 
+	skb_shinfo(nskb)->tso_size = 0;
+	skb_shinfo(nskb)->tso_segs = 0;
+
 	tcph = (struct tcphdr *)((u_int32_t*)nskb->nh.iph + nskb->nh.iph->ihl);
 
 	/* Swap source and dest */
