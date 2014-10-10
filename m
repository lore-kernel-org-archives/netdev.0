From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH] flow-dissector: Fix alignment issue in __skb_flow_get_ports
Date: Fri, 10 Oct 2014 11:53:35 -0700
Message-ID: <54382B2F.8030203@redhat.com>
References: <20141010.135851.1743803688676076555.davem@davemloft.net>	<54381F1C.2030800@gmail.com>	<20141010.141559.2024576018585843684.davem@davemloft.net> <20141010.142255.359367991309840826.davem@davemloft.net>
Reply-To: alexander.h.duyck@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, David.Laight@ACULAB.COM,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16034 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751356AbaJJSxl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Oct 2014 14:53:41 -0400
In-Reply-To: <20141010.142255.359367991309840826.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/2014 11:22 AM, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Fri, 10 Oct 2014 14:15:59 -0400 (EDT)
>
>> Your original code works because you do things like "byte[12] & 0xf0" to
>> extract these fields.
> Changing that th->doff sequence to instead be:
>
> 		const u8 *bp;
> 		u8 buf[13];
>
> 		bp = __skb_header_pointer(skb, poff, sizeof(buf),
> 					  data, hlen, &buf);
> 		if (!bp)
> 			return poff;
>
> 		poff += max_t(u32, sizeof(struct tcphdr), (bp[12] & 0xf0) >> 2);
> 		break;
>
> on top of your v3 patch works for me.
>
> Please double-check my calculations.

Any reason why you are grabbing all 13 bytes instead of just the 1 we 
care about?  Seems like we could just use a u8 buf instead of the array 
since we are only grabbing doff.

Thanks,

Alex
