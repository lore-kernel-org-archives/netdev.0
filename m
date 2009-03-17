From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [patch 0/6] netfilter: ctnetlink allocation improvement
Date: Tue, 17 Mar 2009 11:24:51 +0100
Message-ID: <49BF7A73.3010605@netfilter.org>
References: <20090316220659.756862181@jonathan.eitzenberger.org> <49BF28A3.3010606@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Holger Eitzenberger <holger@eitzenberger.org>,
	David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42765 "EHLO us.es"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757751AbZCQKY7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2009 06:24:59 -0400
In-Reply-To: <49BF28A3.3010606@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Patrick,

Patrick McHardy wrote:
> These patches look almost perfect, there's just one minor thing
> that should be fixed from my perspective (from patch 4):
> 
>> +    l3proto = nf_ct_l3proto_find_get(tuple->src.l3num);
>> +    len += l3proto->nla_size;
>> +    nf_ct_l3proto_put(l3proto);
>> +
>> +    l4proto = nf_ct_l4proto_find_get(tuple->src.l3num,
>> tuple->dst.protonum);
>> +    len += l4proto->nla_size;
>> +    nf_ct_l4proto_put(l4proto);
>> +
>> +    return alloc_skb(len, gfp);
> 
> Its preferrable not to use module reference counting during packet
> processing, the protocols can be accessed safely using RCU. I thought
> I had fixed all those areas, but I now notice that ctnetlink is full
> of similar spots and takes and drops module references quite
> excessively. So just leave it as it is I guess, this should be fully
> fixed anyways.

Indeed, there are still a couple of module reference spots. We only
remove them from the event delivery path.

> I'll wait a few hours for others to comment before applying your
> patches.

Hm, it seems that our patches follows two different principles. AFAICS,
Holger calculates an approximate message size to avoid trimming, while I
calculate the exact message size.

-- 
"Los honestos son inadaptados sociales" -- Les Luthiers
