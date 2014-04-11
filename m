From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] packet: fix potential use after free
Date: Sat, 12 Apr 2014 01:37:30 +0200
Message-ID: <53487CBA.7080009@redhat.com>
References: <1397092959.16584.26.camel@edumazet-glaptop2.roam.corp.google.com> <53465409.3070507@redhat.com> <1397142418.16584.28.camel@edumazet-glaptop2.roam.corp.google.com> <20140411.155922.2269056965511687739.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, xii@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53866 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750842AbaDKXhi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2014 19:37:38 -0400
In-Reply-To: <20140411.155922.2269056965511687739.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/11/2014 09:59 PM, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 10 Apr 2014 08:06:58 -0700
>
>> On Thu, 2014-04-10 at 10:19 +0200, Daniel Borkmann wrote:
>>> On 04/10/2014 03:22 AM, Eric Dumazet wrote:
>>>> From: Eric Dumazet <edumazet@google.com>
>>>>
>>>> As soon skb is queued into sk_receive_queue, it can be consumed,
>>>> so its racy to access skb->len.
>>>>
>>>> Given that sk_data_ready() / sock_def_readable() don't really care, just
>>>> use 0 instead of skb->len
>>>>
>>>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>>>> Cc: Xi Wang <xii@google.com>
>>>
>>> Acked-by: Daniel Borkmann <dborkman@redhat.com>
>>>
>>> Seems to be there since pre 2005 ...
>>
>> Yeah, and many other places have the same error, a full audit is
>> probably needed.
>
> Not only sock_def_readable(), but all implementations of this callback absolutely
> do not care about the length argument.
>
> I'm working on a patch to kill the argument completely.

Sounds good! Seen you've already pushed that, thanks!
