From: Ingo Kofler <ikofler@edu.uni-klu.ac.at>
Subject: Re: Problems obtaining software TX timestamps
Date: Thu, 09 Sep 2010 10:26:06 +0200
Message-ID: <4C889A1E.6050405@edu.uni-klu.ac.at>
References: <4C877D8A.6040002@edu.uni-klu.ac.at> <1283958771.2748.85.camel@edumazet-laptop> <4C87FE60.7090209@edu.uni-klu.ac.at> <20100909063541.GA3305@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailsrv.uni-klu.ac.at ([143.205.180.44]:49812 "EHLO
	mailsrv.uni-klu.ac.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751497Ab0III0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 04:26:08 -0400
In-Reply-To: <20100909063541.GA3305@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Richard Cochran wrote:
> On Wed, Sep 08, 2010 at 11:21:36PM +0200, Ingo Kofler wrote:
>   
>> Ok, for hardware timestamps it seems logically for me that the
>> driver has to support this. But what about the software timestamps -
>> do they also require support from the driver? Is there no generic
>> implementation in the networking stack?
>>     
>
> There was once a completely generic implementation, but the Tx path
> had issues. The generic Tx SW code was reverted in
>
> cd4d8fdad1f13205c769266dfa99015e226b6e07
>
> Now, there is a way to support this again, but it requires adding one
> line into each and every MAC driver. It is not very hard to do:
>
> linux/skbuff.h:1992
> /**
>  * skb_tx_timestamp() - Driver hook for transmit timestamping
>  *
>  * Ethernet MAC Drivers should call this function in their hard_xmit()
>  * function as soon as possible after giving the sk_buff to the MAC
>  * hardware, but before freeing the sk_buff.
>  *
>  * @skb: A socket buffer.
>  */
> static inline void skb_tx_timestamp(struct sk_buff *skb);
>
> I am already carrying patches for this privately. If you post a patch
> for your MAC, then you can be the first one to support this feature! ;^)
>   
Thank you very much for this clarification. Are there any drawbacks with 
this approach, e.g. performance issues? Honestly, I am just wondering 
why driver developers do not add this single line if it's that easy....

Ingo
> Richard
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>   

