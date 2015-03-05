From: B Viswanath <marichika4@gmail.com>
Subject: Re: [ovs-dev] OVS Offload Decision Proposal
Date: Thu, 5 Mar 2015 22:03:51 +0530
Message-ID: <CAN+pFwJ6XoCghw9uHb5UA88o8zoXqGNhEnVHPQWrOV1p=O-15Q@mail.gmail.com>
References: <54F7B76E.4040902@gmail.com>
	<20150305.000015.1427044514000703740.davem@davemloft.net>
	<CA+mtBx_Q5Zp58ZkBB0oeyHm5NC8sg1kx=uzTN_8TYG6zYh8yUA@mail.gmail.com>
	<20150305.014257.974664546228241067.davem@davemloft.net>
	<54F80815.5030208@gmail.com>
	<54F84E21.7030207@mojatatu.com>
	<54F8572B.4020309@mojatatu.com>
	<54F86D9E.7000200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	davidch@broadcom.com, simon.horman@netronome.com,
	dev@openvswitch.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	pablo@netfilter.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:39678 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834AbbCEQdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 11:33:51 -0500
Received: by pabrd3 with SMTP id rd3so10261143pab.6
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 08:33:51 -0800 (PST)
In-Reply-To: <54F86D9E.7000200@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5 March 2015 at 20:22, John Fastabend <john.fastabend@gmail.com> wrote:
> On 03/05/2015 05:16 AM, Jamal Hadi Salim wrote:
>>
<snip>
>>>> Once the reservation of resources occurs we wouldn't let user space
>>>> arbitrarily write to any table but only tables that have been
>>>> explicitly reserved for user space to write to.
>>
>>
>> Seems i misread what you are saying.
>> I thought you wanted to just create the tables from user space
>> directly; however, rereading the above:
>> you are actually  asking *to write* to these tables directly from user
>> space ;->
>>
>>
>
> Actually I was proposing both. But I can see a workaround for the set
> rule or *to write* by mapping a new xflow classifier onto my hardware.
> Not ideal for my work but I guess it might be possible.
>
> The 'create' table from user space though I don't see any good work
> around for. You need this in order to provide some guidance to the
> driver otherwise we have to try and "guess" what the table size slicing
> should look like and this can create rather large variations in how
> many rules fit in the table think 100 - 100k difference. Also at least
> on the hardware I have this is not dynamic I can't start adding rules
> to a table and then do a resizing later without disrupting the traffic.
> It would be interesting for folks working on other switch devices to
> chime in.

Some of these abstractions are a little tough to map into for me.
Probably I need more reading.  But it is very interesting to follow
the central resource manager notion. The question being asked is where
this will be, user space or kernel space.

The drivers (and the SDKs) I have worked upon provided a simple add
rule , delete rule notion. They have hidden away the complexity of how
it is managing stuff inside. They do tend to be complicated. For
example, the simple question of how many rules can be supported inside
a chip, doesn't have a single answer. It depends on how deep the
packets need to be looked into, how many tags the packets are expected
to be supported, ipv6, tunnels, tunnels inside tunnels and many other
factors. Depending on the chip, some of the standard operations (such
as vlans) are managed via rules, and some chips support them natively.
This knowledge tends to be chip specific and very likely varies from
chip to chip and manufacturer to manufacturer.

Given this, the place the 'resources (rules)' need to be managed
should be close to the chip, the driver. Kernel ? May be. It needs to
define lot of 'generic' interfaces and manage in a single place. User
space ? I don't think it can do it, not for the chips I am aware of.
Note that by 'user space', I  mean close to user and not an SDK
running in user space.


>
> Also just to the point out even in the 'set' case we wouldn't let
> arbitrary 'set rule' writes hit the hardware we would verify the rule
> set is for a table that is pre-defined for it and that the rule itself
> is well-formed. In that sense the xflow classifier path is not
> particularly different.
>
> cheers,
>>
>> jamal
>
>
>
> --
> John Fastabend         Intel Corporation
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
