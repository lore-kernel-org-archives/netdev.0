From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 02/11] net: add function to allocate skbuff head without
 data area
Date: Wed, 07 Sep 2011 17:20:42 +0200
Message-ID: <4E678BCA.6070102@trash.net>
References: <1315070771-18576-1-git-send-email-kaber@trash.net>	 <1315070771-18576-3-git-send-email-kaber@trash.net> <1315123938.2635.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61794 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754662Ab1IGQQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2011 12:16:28 -0400
In-Reply-To: <1315123938.2635.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04.09.2011 10:12, Eric Dumazet wrote:
> Le samedi 03 septembre 2011 =E0 19:26 +0200, kaber@trash.net a =E9cri=
t :
>=20
>> +struct sk_buff *__alloc_skb_head(gfp_t gfp_mask, int node)
>> +{
>> +	struct sk_buff *skb;
>> +
>> +	/* Get the HEAD */
>> +	skb =3D kmem_cache_alloc_node(skbuff_head_cache,
>> +				    gfp_mask & ~__GFP_DMA, node);
>> +	if (!skb)
>> +		goto out;
>> +	prefetchw(skb);
>=20
> Please remove this prefetchw(), since we have no delay between it and
> actual memset(skb).

Done, thanks.
