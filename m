From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [ovs-dev] OVS Offload Decision Proposal
Date: Thu, 05 Mar 2015 06:52:14 -0800
Message-ID: <54F86D9E.7000200@gmail.com>
References: <54F7B76E.4040902@gmail.com> <20150305.000015.1427044514000703740.davem@davemloft.net> <CA+mtBx_Q5Zp58ZkBB0oeyHm5NC8sg1kx=uzTN_8TYG6zYh8yUA@mail.gmail.com> <20150305.014257.974664546228241067.davem@davemloft.net> <54F80815.5030208@gmail.com> <54F84E21.7030207@mojatatu.com> <54F8572B.4020309@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	davidch@broadcom.com, simon.horman@netronome.com,
	dev@openvswitch.org, netdev@vger.kernel.org, pablo@netfilter.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:35054 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752966AbbCEOwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 09:52:30 -0500
Received: by obbgq1 with SMTP id gq1so14273523obb.2
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 06:52:30 -0800 (PST)
In-Reply-To: <54F8572B.4020309@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/05/2015 05:16 AM, Jamal Hadi Salim wrote:
> On 03/05/15 07:37, Jamal Hadi Salim wrote:
>> On 03/05/15 02:39, John Fastabend wrote:
>
>> Would kernel boot/module options passed to the driver not suffice?
>> That implies a central authority that decides what these table size
>> slicing looks like.
>>

The problem with boot/module options is they are really difficult to
manage from a controller agent. And yes in most cases I am working on
there is central authority that "knows" how to map the network policy
onto a set of table size slices. At least in my space I don't believe
people are logging into systems and using the CLI except for debugging
and experimenting.

>>> Once the reservation of resources occurs we wouldn't let user space
>>> arbitrarily write to any table but only tables that have been
>>> explicitly reserved for user space to write to.
>
> Seems i misread what you are saying.
> I thought you wanted to just create the tables from user space
> directly; however, rereading the above:
> you are actually  asking *to write* to these tables directly from user
> space ;->
>
>

Actually I was proposing both. But I can see a workaround for the set
rule or *to write* by mapping a new xflow classifier onto my hardware.
Not ideal for my work but I guess it might be possible.

The 'create' table from user space though I don't see any good work
around for. You need this in order to provide some guidance to the
driver otherwise we have to try and "guess" what the table size slicing
should look like and this can create rather large variations in how
many rules fit in the table think 100 - 100k difference. Also at least
on the hardware I have this is not dynamic I can't start adding rules
to a table and then do a resizing later without disrupting the traffic.
It would be interesting for folks working on other switch devices to
chime in.

Also just to the point out even in the 'set' case we wouldn't let
arbitrary 'set rule' writes hit the hardware we would verify the rule
set is for a table that is pre-defined for it and that the rule itself
is well-formed. In that sense the xflow classifier path is not
particularly different.

cheers,
> jamal


-- 
John Fastabend         Intel Corporation
