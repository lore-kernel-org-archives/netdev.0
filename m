From: Paul Chavent <paul.chavent@fnac.net>
Subject: Re: [PATCH net-next v2] packet: tx_ring: allow the user to choose
 tx data offset
Date: Wed, 31 Oct 2012 22:22:07 +0100
Message-ID: <5091967F.9050907@fnac.net>
References: <1350889014-2975-1-git-send-email-paul.chavent@onera.fr> <20121031.131434.910561089094397853.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul.Chavent@onera.fr, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:57346 "EHLO smtp5-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933501Ab2JaVWJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2012 17:22:09 -0400
In-Reply-To: <20121031.131434.910561089094397853.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/31/2012 06:14 PM, David Miller wrote:
> From: Paul Chavent <Paul.Chavent@onera.fr>
> Date: Mon, 22 Oct 2012 08:56:54 +0200
>
>> +		if (unlikely((off < off_min) || (off_max < off))) {
>> +			pr_err("payload offset (%d) out of range [%d;%d]\n",
>> +				off, off_min, off_max);
>> +			return -EINVAL;
>> +		}
>
> Users should not be able to spam the kernel log with error messages
> by simply make setsockopt() calls.
>
> This error log is inappropriate.

This error log is thrown when the user call send, not setsockopt !

It seems that the user can already fire an error msg by simply pass a too long tp_len.

Though, should i remove it from the tpacket_fill_skb function and silently return -EINVAL ?


>> @@ -110,6 +110,7 @@ struct packet_sock {
>>   	unsigned int		tp_reserve;
>>   	unsigned int		tp_loss:1;
>>   	unsigned int		tp_tstamp;
>> +	unsigned int		tp_tx_has_off:1;
>>   	struct packet_type	prot_hook ____cacheline_aligned_in_smp;
>>   };
>
> Please put the new bit field next to other existing bit fields so that
> there is less wasted space in the struct.

OK.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
