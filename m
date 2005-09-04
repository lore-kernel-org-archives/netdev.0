From: Patrick McHardy <kaber@trash.net>
Subject: Re: Kernel 2.6.13 breaks libpcap (and tcpdump).
Date: Sun, 04 Sep 2005 19:06:13 +0200
Message-ID: <431B2985.1060502@trash.net>
References: <E1EBpkT-0001RP-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, jmcgowan@inch.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932065AbVIDRG2@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1EBpkT-0001RP-00@gondolin.me.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> We aren't handling the reading of specific fields like the IP protocol
> field correctly.  This patch should make it work again.

I can't spot the problem, could you give me a hint?

> I tried to move this logic into the new load_pointer function but it
> all came out messy so I simply rolled it back.

  		case BPF_LD|BPF_W|BPF_ABS:
  			k = fentry->k;
   load_w:
-			ptr = load_pointer(skb, k, 4, &tmp);
+			if (k >= 0)
+				ptr = skb_header_pointer(skb, k, 4, &tmp);
+			else if (k < SKF_AD_OFF)
+				ptr = load_pointer(skb, k);
+			else
+				break;

The old value of ptr will be used in this case, it should
be explicitly set to NULL to abort.
