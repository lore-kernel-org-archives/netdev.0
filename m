From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] udp: properly support MSG_PEEK with truncated
 buffers
Date: Mon, 04 Jan 2016 17:25:13 -0500 (EST)
Message-ID: <20160104.172513.383473031591056204.davem@davemloft.net>
References: <20151228153836.GA28529@unicorn.suse.cz>
	<1451322610.8255.3.camel@edumazet-glaptop2.roam.corp.google.com>
	<1451483472.8255.16.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mkubecek@suse.cz, sd@queasysnail.net, stable@vger.kernel.org,
	jslaby@suse.cz, ben@decadent.org.uk, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48961 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751913AbcADWZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 17:25:15 -0500
In-Reply-To: <1451483472.8255.16.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 30 Dec 2015 08:51:12 -0500

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

Applied, thanks Eric.
