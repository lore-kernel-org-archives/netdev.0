From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next] udp: properly support MSG_PEEK with truncated
 buffers
Date: Thu, 31 Dec 2015 06:39:44 +0800
Message-ID: <20151230223944.GA13450@gondor.apana.org.au>
References: <20151228140157.6F592A0C7D@unicorn.suse.cz>
 <20151228142942.GA7394@bistromath.redhat.com>
 <20151228153836.GA28529@unicorn.suse.cz>
 <1451322610.8255.3.camel@edumazet-glaptop2.roam.corp.google.com>
 <1451483472.8255.16.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Kubecek <mkubecek@suse.cz>,
	David Miller <davem@davemloft.net>,
	Sabrina Dubroca <sd@queasysnail.net>, stable@vger.kernel.org,
	Jiri Slaby <jslaby@suse.cz>,
	Ben Hutchings <ben@decadent.org.uk>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:33998 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750904AbbL3WkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 17:40:03 -0500
Content-Disposition: inline
In-Reply-To: <1451483472.8255.16.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 30, 2015 at 08:51:12AM -0500, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Backport of this upstream commit into stable kernels :
> 89c22d8c3b27 ("net: Fix skb csum races when peeking")
> exposed a bug in udp stack vs MSG_PEEK support, when user provides
> a buffer smaller than skb payload.
>     
> In this case,
> skb_copy_and_csum_datagram_iovec(skb, sizeof(struct udphdr),
>                                  msg->msg_iov);
> returns -EFAULT.
>     
> This bug does not happen in upstream kernels since Al Viro did a great
> job to replace this into :
> skb_copy_and_csum_datagram_msg(skb, sizeof(struct udphdr), msg);
> This variant is safe vs short buffers.
>     
> For the time being, instead reverting Herbert Xu patch and add back
> skb->ip_summed invalid changes, simply store the result of
> udp_lib_checksum_complete() so that we avoid computing the checksum a
> second time, and avoid the problematic
> skb_copy_and_csum_datagram_iovec() call.
> 
> This patch can be applied on recent kernels as it avoids a double
> checksumming, then backported to stable kernels as a bug fix.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
