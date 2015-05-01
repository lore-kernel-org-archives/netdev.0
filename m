From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH -next] net: sched: remove TC_MUNGED bits
Date: Thu, 30 Apr 2015 20:43:17 -0400
Message-ID: <5542CC25.8060501@mojatatu.com>
References: <1430388720-5112-1-git-send-email-fw@strlen.de> <20150430211620.GA13076@Alexeis-MBP.westell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:37579 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485AbbEAAnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 20:43:19 -0400
Received: by igblo3 with SMTP id lo3so28171839igb.0
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 17:43:18 -0700 (PDT)
In-Reply-To: <20150430211620.GA13076@Alexeis-MBP.westell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/30/15 17:16, Alexei Starovoitov wrote:
> On Thu, Apr 30, 2015 at 12:12:00PM +0200, Florian Westphal wrote:
>> Not used.
>>
>> pedit sets TC_MUNGED when packet content was altered, but all the core
>> does is unset MUNGED again and then set OK2MUNGE.
>>
>> And the latter isn't tested anywhere. So lets remove both
>> TC_MUNGED and TC_OK2MUNGE.
>>
>> Signed-off-by: Florian Westphal <fw@strlen.de>
>
> Wanted to do the same.
> iproute2 doesn't use 'munge' flag either.
>
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>
>

Florian,
If you are going to take this path then fix pedit to do a pskb_expand.

I think it would be better to fix the actions that do
pskb_expand_head() and let them indicated they were munged.
The flag was intended to be an optimization where it would indicate
to the action processing a packet to not bother and just trample
on the packet if noone is referencing it.
That was the rule, unfortunately nobody paid attention and it
didnt matter because it doesnt seem there was a use case where two
actions in a graph would be editing packets one after the other).

cheers,
jamal
