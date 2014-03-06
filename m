From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Can I limit the number of active tx per TCP socket?
Date: Thu, 06 Mar 2014 11:06:04 -0800
Message-ID: <5318C71C.1020807@hp.com>
References: <063D6719AE5E284EB5DD2968C1650D6D0F6D3B91@AcuExch.aculab.com> <5318ADB1.5050107@hp.com> <CADVnQyn1+WRqS9HQmMn9JgpBz0Wajg=40yVhdyqv_AAo4tpWUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@aculab.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3427.houston.hp.com ([15.201.208.55]:55905 "EHLO
	g4t3427.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752153AbaCFTGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 14:06:05 -0500
In-Reply-To: <CADVnQyn1+WRqS9HQmMn9JgpBz0Wajg=40yVhdyqv_AAo4tpWUA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/06/2014 10:09 AM, Neal Cardwell wrote:
> Eric's recent "auto corking" feature may be helpful in this context:
>
>    http://lwn.net/Articles/576263/

Doesn't that depend on the bottleneck being local to the sending side? 
Perhaps I've mis-understood David's setup, but I get the impression the 
bottleneck is not at the sending side but either in the middle or at the 
end, so tx completions will still be happening quickly.

rick

> neal
>
> On Thu, Mar 6, 2014 at 12:17 PM, Rick Jones <rick.jones2@hp.com> wrote:
>> On 03/06/2014 04:28 AM, David Laight wrote:
>>>
>>> Is it possible to stop a TCP connection having more than one
>>> tx skb (in the ethernet tx ring) at any one time?
>>> The idea is to allow time for short sends from the application
>>> to accumulate so that the transmitted frames are longer.
>>
>>
>> That is precisely what Nagle is supposed to be doing - at least where the
>> definition of "time" is the round-trip-time rather than "time it takes to
>> get transmitted out the NIC."
>>
>>
>>> Basically I have a TCP connection which carries a lot of separate
>>> short 'user buffers'. These are not command-response so
>>> TCP_NODELAY has to be set to avoid long delays.
>>
>>
>> When you are saturating the receiver and/or the 64K line, are you certain
>> that not setting TCP_NODELAY means long delays?
>>
>>  From a later message:
>>
>>
>>> The data is sent out on a 64k line so 1ms is only 8 byte times.
>>
>>
>> Are you still using a 1460 byte MSS on such a connection?
>>
>> Perhaps you can set the MSS (or drop the MTU on the 64K line and use PTMU)
>> to something less to trigger window updates a bit sooner and so get
>> piggy-backed ACKs rather than delayed ACKs and so not have to set
>> TCP_NODELAY?  Yes, you will have a question of headers versus headers+data
>> but with TCP_NODELAY set as you have it you are (probably) already trashing
>> that.
>>
>> Setting TCP_NODELAY to avoid "long delays" and then having a 64Kbyte/s link
>> seems a trifle, well, contradictory.
>>
>> rick jones
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
