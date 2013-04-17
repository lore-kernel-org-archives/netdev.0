From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next 4/9] net: sctp: sctp_outq: consolidate chars
 into bitfield
Date: Wed, 17 Apr 2013 11:44:11 -0400
Message-ID: <516EC34B.1040503@gmail.com>
References: <1366146438-8815-1-git-send-email-dborkman@redhat.com> <1366146438-8815-5-git-send-email-dborkman@redhat.com> <AE90C24D6B3A694183C094C60CF0A2F6026B71DC@saturn3.aculab.com> <516E6ABD.2040904@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f43.google.com ([209.85.216.43]:33338 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965236Ab3DQPoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 11:44:15 -0400
In-Reply-To: <516E6ABD.2040904@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/17/2013 05:26 AM, Daniel Borkmann wrote:
> On 04/17/2013 10:43 AM, David Laight wrote:
>>>       __u32 outstanding_bytes;
>>>
>>> -    /* Are we doing fast-rtx on this queue */
>>> -    char fast_rtx;
>>> -
>>> -    /* Corked? */
>>> -    char cork;
>>> -
>>> -    /* Is this structure empty?  */
>>> -    char empty;
>>> +    __u8 fast_rtx:1,    /* Are we doing fast-rtx on this queue */
>>> +         cork:1,        /* Corked? */
>>> +         empty:1;        /* Is this structure empty?  */
>>>   };
>>
>> Use of bitfields just makes the code slower.
>> The only real excuse for using them is to reduce the size
>> of a structure that is allocated a lot.
>
> sctp_outq is _embedded_ into an sctp_association structure, which
> has [size: 2280, cachelines: 36, members: 76]! A next step would be
> to try to reorder its elements carefully and see if we can reduce
> the size by filling some holes.

I remember attempting this undertaking that led me down the rabbit hole 
so fast that my head started to spin.  It is a badly needed project, but 
be prepared to spend a lot of time on it.

Not sure if the space saving is worth the bad code generated for 
bit-fields, especially considering that empty and cork are used on 
almost every packet.

-vlad

> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
