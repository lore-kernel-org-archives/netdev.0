From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Fix bug of update IPv4 PMTU when received ICMP Fragmentation Needed message
Date: Sat, 02 Jun 2007 20:49:19 +1000
Message-ID: <E1HuRAd-0002Wl-00@gondolin.me.apana.org.au>
References: <465F97CF.1060508@cn.fujitsu.com>
Cc: netdev@vger.kernel.org
To: yjwei@cn.fujitsu.com (Wei Yongjun)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4667 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751570AbXFBKt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2007 06:49:27 -0400
In-Reply-To: <465F97CF.1060508@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wei Yongjun <yjwei@cn.fujitsu.com> wrote:
> When received ICMP Fragmentation Needed message, PATH MTU is always set 
> to the 576 even if MTU in ICMP message is lager then 576. This is 
> because of error condition in function ip_rt_frag_needed(), now if 
> packet size of that ICMP message is less then new MTU, packet size will 
> be used ,but RFC says ICMP error message return as much as we can 
> without exceeding 576 bytes.
> 
> This patch has Fixed this BUG.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> 
> --- net/ipv4/route.c.orig       2007-05-25 05:22:47.000000000 +0800
> +++ net/ipv4/route.c    2007-06-01 11:42:55.000000000 +0800
> @@ -1424,7 +1424,7 @@ unsigned short ip_rt_frag_needed(struct 
>                            !(dst_metric_locked(&rth->u.dst, RTAX_MTU))) {
>                                unsigned short mtu = new_mtu;
> 
> -                               if (new_mtu < 68 || new_mtu >= old_mtu) {
> +                               if (new_mtu < 68) {
> 
>                                        /* BSD 4.2 compatibility hack :-( */

Huh? The test new_mtu >= old_mtu should only hold if the sending router
is buggy which is what the hack is for.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
