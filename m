From: Florian Westphal <fw@strlen.de>
Subject: Re: [patch 0/6] netfilter: ctnetlink allocation improvement
Date: Tue, 17 Mar 2009 10:07:56 +0100
Message-ID: <20090317090756.GF18729@Chamillionaire.breakpoint.cc>
References: <20090316220659.756862181@jonathan.eitzenberger.org> <49BF28A3.3010606@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Holger Eitzenberger <holger@eitzenberger.org>,
	David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:36699 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752049AbZCQJIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 05:08:00 -0400
Content-Disposition: inline
In-Reply-To: <49BF28A3.3010606@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> wrote:
>> +	l3proto = nf_ct_l3proto_find_get(tuple->src.l3num);
>> +	len += l3proto->nla_size;
>> +	nf_ct_l3proto_put(l3proto);
>> +
>> +	l4proto = nf_ct_l4proto_find_get(tuple->src.l3num, tuple->dst.protonum);
>> +	len += l4proto->nla_size;
>> +	nf_ct_l4proto_put(l4proto);
>> +
>> +	return alloc_skb(len, gfp);
>
> Its preferrable not to use module reference counting during packet
> processing, the protocols can be accessed safely using RCU. I thought
> I had fixed all those areas, but I now notice that ctnetlink is full
> of similar spots and takes and drops module references quite
> excessively. So just leave it as it is I guess, this should be fully
> fixed anyways.

I'll look into converting all those spots to RCU.

Thanks, Florian
