From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH 2/2 net-next] net: move qdisc ingress filtering code where
 it belongs
Date: Sun, 10 May 2015 11:05:28 -0700
Message-ID: <554F9DE8.3000507@plumgrid.com>
References: <1431277170-4618-1-git-send-email-pablo@netfilter.org> <1431277170-4618-3-git-send-email-pablo@netfilter.org> <554F9946.9040707@plumgrid.com> <20150510175934.GA3799@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
	daniel@iogearbox.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:33183 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549AbbEJSFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 14:05:31 -0400
Received: by iepj10 with SMTP id j10so90763155iep.0
        for <netdev@vger.kernel.org>; Sun, 10 May 2015 11:05:31 -0700 (PDT)
In-Reply-To: <20150510175934.GA3799@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/10/15 10:59 AM, Pablo Neira Ayuso wrote:
> On Sun, May 10, 2015 at 10:45:42AM -0700, Alexei Starovoitov wrote:
>> On 5/10/15 9:59 AM, Pablo Neira Ayuso wrote:
>>> The qdisc ingress filtering code is embedded into the core most likely because
>>> at that time we had no RCU in place to define a hook. This is semantically
>>> wrong as this violates the most basic rules of encapsulation.
>>
>> Yet another attempt to sneak in 'qdisc_ingress_hook' to kill TC ?
>> Just add another hook for netfilter. Seriously. Enough of these
>> politics.
>
> Absolutely not. I will not kill TC because people like jamal likes it,
> and that's more than an argument to me to keep it there.
>
> I have to ask you to stop harassing me all over with non-technical
> comments: "evil", "funny", ...

Please, I never called you 'evil'. Though we're arguing, it's ok,
because we both want the best for the kernel. We just not on the same
page yet.
'funny' also doesn't apply to you.
If you feel offended, I'm sorry. I didn't mean it at all.

> I'm getting quite enough of this, you stop that.

agree. let's articulate on exact technical means.
So, please, state clearly why you so much insisting of combining
existing tc and future netfilter hook into one that creates long
term head aches? What is wrong with two hooks?

>> Again, Daniel's patch accelerates super-critical ingress path even more.
>> Care to carefully read it first?
>
> No, Daniel is *not* benchmarking the netif_received_core() with no
> filtering at all.

sorry, not true. We did benchmark all combinations. Daniel posted
his, I'll send numbers from my box as well.
