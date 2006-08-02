From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [PATCH 7/23] [PATCH] [XFRM] STATE: Add a hook to find where to
 be inserted header in outbound.
Date: Wed, 02 Aug 2006 11:20:30 +0900
Message-ID: <44D00BEE.8090504@linux-ipv6.org>
References: <11541654231584-git-send-email-nakam@linux-ipv6.org> <20060801.170916.21925105.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:61073 "EHLO mail.gomagoma.org")
	by vger.kernel.org with ESMTP id S1751047AbWHBCUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 22:20:33 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060801.170916.21925105.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Date: Sat, 29 Jul 2006 18:30:23 +0900
> 
>> @@ -270,6 +270,7 @@ struct xfrm_type
>>  	void			(*destructor)(struct xfrm_state *);
>>  	int			(*input)(struct xfrm_state *, struct sk_buff *skb);
>>  	int			(*output)(struct xfrm_state *, struct sk_buff *pskb);
>> +	int			(*place_find)(struct xfrm_state *, struct sk_buff *, u8 **);
>>  	/* Estimate maximal size of result of transformation of a dgram */
>>  	u32			(*get_max_size)(struct xfrm_state *, int size);
>>  };
> 
> I see a dangerous pattern of adding many, many, many methods
> to the xfrm_type structure which are only used by ipv6.
> But I cannot suggest another method.

Sometimes this is a difficult point for me to design.


> There are frequent calls of the form:
> 
> 	if (x->type->op != NULL)
> 		x->type->op(x, y, z);
> 	else
> 		foo(y, z);
> 
> it might be nicer to hide all of this behind carefully crafted
> inline functions.

I'll fix it. James gave me this comment, too.

BTW he also gave me another point:

> Maybe also change the naming of ->place_find to ->hdr_offset

I'll use this idea, too.

Thank you.

-- 
Masahide NAKAMURA
