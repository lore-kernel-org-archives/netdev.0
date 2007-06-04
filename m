From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Fix bug of update IPv4 PMTU when received ICMP Fragmentation Needed message
Date: Mon, 4 Jun 2007 14:55:06 +1000
Message-ID: <20070604045506.GA28580@gondor.apana.org.au>
References: <E1HuRAd-0002Wl-00@gondolin.me.apana.org.au> <46635F39.2090009@cn.fujitsu.com> <20070604025528.GA27750@gondor.apana.org.au> <46638F2D.90608@cn.fujitsu.com> <20070604041406.GA28263@gondor.apana.org.au> <466395F1.7060003@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3171 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751534AbXFDEzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 00:55:13 -0400
Content-Disposition: inline
In-Reply-To: <466395F1.7060003@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 04, 2007 at 12:32:49PM +0800, Wei Yongjun wrote:
>
> The latest kernel 2.6.21.3 also doing so. The rule to send ICMP message 
> limit this.
> Ref to net/ipv4/icmp.c
> line 433 void icmp_send(struct sk_buff *skb_in, int type, int code, 
> __be32 info)
> line 434 {
> ...
> line 572    /* RFC says return as much as we can without exceeding 576 
> bytes. */
> line 573
> line 574    room = dst_mtu(&rt->u.dst);
> line 575    if (room > 576)
> line 576        room = 576;
> line 577    room -= sizeof(struct iphdr) + icmp_param.replyopts.optlen;
> line 578    room -= sizeof(struct icmphdr);
> line 579
> line 560    icmp_param.data_len = skb_in->len - icmp_param.offset;
> line 561    if (icmp_param.data_len > room)
> line 562        icmp_param.data_len = room;
> line 563    icmp_param.head_len = sizeof(struct icmphdr);
> 
> line 576 do this.

But this is not the old_mtu field that we were talking about.  The
old_mtu field comes from iph->tot_len which is the length of field
in the *original* IP header.  We're certainly not allowed touch that
field.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
