From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: WARNING: at net/core/skbuff.c:154 with tcpdump and ipsec
Date: Fri, 13 Feb 2009 13:56:01 -0500
Message-ID: <4995C241.1030507@hp.com>
References: <20090213121424.GA8717@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Oledzki <ole@ans.pl>,
	Marco Berizzi <pupilla@hotmail.com>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:23743 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751064AbZBMS4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2009 13:56:05 -0500
In-Reply-To: <20090213121424.GA8717@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On 11-02-2009 16:55, Krzysztof Oledzki wrote:
>> On Wed, 11 Feb 2009, Marco Berizzi wrote:
>>
>>> Hi Folks,
>>>
>>> I'm getting this error on 2.6.28.4 when I run tcpdump on
>>> the interface where ipsec packets are enc/decrypted.
>>>
>>> TIA
>>>
>>>> Feb 11 10:53:55 Pleiadi kernel: ------------[ cut here ]------------
>>>> Feb 11 10:53:55 Pleiadi kernel: WARNING: at net/core/skbuff.c:154 skb_truesize_bug+0x2e/0x33()
>>>> Feb 11 10:53:55 Pleiadi kernel: SKB BUG: Invalid truesize (268) len=134, sizeof(sk_buff)=172
>> <CUT>
>>
>> This annoying problem is quite old (appeared in 2.6.25) and already known:
>>   http://bugzilla.kernel.org/show_bug.cgi?id=10996
>>
>> Sadly, no one is interested in fixing it. :(
> 
> Here is a debugging patch doing these checks a bit earlier, so maybe
> we get something new and interesting. ;)
> 
> Thanks,
> Jarek P.
> ---
> 

I did notice that pskb_expand_head() doesn't change the skb->truesize even
though it could grow the skb.  I saw this problem with tcpdump while
experimenting with some SCTP code.

This is not to say that it is the problem in this case, but it's one of
them that I've seen.

-vlad
