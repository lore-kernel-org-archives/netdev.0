From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [RFC PATCH v1.0] af_packet: don't emit packet on orig fanout
 group
Date: Fri, 17 Aug 2012 16:03:11 +0800
Message-ID: <502DFABF.3000906@windriver.com>
References: <1344262918.8024.41.camel@tiger.regit.org>	<1345131890-15991-1-git-send-email-eric@regit.org> <20120816.145200.694410419765575459.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <eric@regit.org>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:33663 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932284Ab2HQIDX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2012 04:03:23 -0400
In-Reply-To: <20120816.145200.694410419765575459.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Eric Leblond <eric@regit.org>
> Date: Thu, 16 Aug 2012 17:44:50 +0200
>
>   
>> If a packet is emitted on one socket in one group of fanout sockets,
>> it is transmitted again. It is thus read again on one of the sockets
>> of the fanout group. This result in a loop for software which
>> generate packets when receiving one.
>> This retransmission is not the intended behavior: a fanout group
>> must behave like a single socket. The packet should not be
>> transmitted on a socket if it originates from a socket belonging
>> to the same fanout group.
>>
>> This patch fixes the issue by changing the transmission check to
>> take fanout group info account.
>>     
>
> This looks mostly fine, thanks for fixing this.
>
> I wonder if it wouldn't be better to simply have a callback?  That
> would eliminate all of the ifdefs:
>
> 	if (ptype->id_match) {
> 		if (ptype->id_match(ptype, skb->sk))
> 			return true;
> 	} else if (ptype->af_packet_priv == skb->sk)
> 		return true;
>
> It's a shame that we have a user of af_packet_priv outside of
> AF_PACKET, in TIPC.  If we could get rid of that we could simplify
> things even futher.
>   

Hi David, next week I will take over the job to get rid the usage of 
af_packet_priv from TIPC.

Regards,
Ying

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>   
