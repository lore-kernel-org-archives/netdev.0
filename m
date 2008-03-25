From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] SCTP: Fix possible memory leak while process INIT chunk
 with AUTH paramters
Date: Tue, 25 Mar 2008 09:03:52 -0400
Message-ID: <47E8F838.1010906@hp.com>
References: <47E20DA8.1080805@cn.fujitsu.com> <47E25794.6050001@hp.com> <47E31A76.6060903@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:47142 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752237AbYCYNDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 09:03:55 -0400
In-Reply-To: <47E31A76.6060903@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wei Yongjun wrote:
> Hi Vlad:
> 
> Vlad Yasevich wrote:
>> Hi Wei
>>
>> Wei Yongjun wrote:
>>> While endpoint received INIT/INIT-ACK chunk with AUTH parameters, 
>>> such as RANDOM, HMAC_ALGO, CHUNKS parameter, if those parameters 
>>> appear more then once, memory for store those parameters will be 
>>> malloc more then once and not free.
>>>
>>
>> All these parameters must be included only once in the packet.
> 
> RFC 4890 has the following text:
> 
>   The RANDOM parameter MUST be included once in the INIT or INIT-ACK
>   chunk, if the sender wants to send or receive authenticated chunks,
>   to provide a 32-byte Random Number.  For 32-byte Random Numbers, the
>   Padding is empty.
> 
> 
> It said *MUST be included once*, not *only once*, is this right?

I guess it depends on the interpretation.  If they are allowed more then
once, then which parameter should be used.  The spec leaves that undefined.

Undefined behavior on a security extension is usually treated as an exploit.
That's my take on this.

> 
>>
>> If these things are included more then once, we should either ABORT or
>> completely ignore the packet.  I haven't decided which one makes more
>> sense yet.
>>
>> If someone when to the trouble of violating the protocol, we should not
>> establish the association with them.
> 
> I think do ABORT with protocol violation is better, do the same thing as 
> the other protocol violation case do.

Yes.

-vlad
> 
> Wei Yongjun
> 

