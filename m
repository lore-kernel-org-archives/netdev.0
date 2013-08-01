From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: locating the 'tc actions' hook
Date: Thu, 01 Aug 2013 07:40:44 -0400
Message-ID: <51FA493C.8080207@mojatatu.com>
References: <51F97F4E.5070102@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	netdev <netdev@vger.kernel.org>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36757 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751177Ab3HALk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 07:40:57 -0400
Received: by mail-pa0-f45.google.com with SMTP id bg4so2041300pad.32
        for <netdev@vger.kernel.org>; Thu, 01 Aug 2013 04:40:56 -0700 (PDT)
In-Reply-To: <51F97F4E.5070102@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-07-31 05:19 PM, John Fastabend wrote:
> Hi Jamal,
>
> I'm trying to sort out why I would use 'tc actions' and exactly
> what it is doing.
>
> Its clear I think adding one or more actions to filters will be
> used in the classifier via tcf_exts_exec() through the classify
> hook called from a qdisc.
>
> This is your standard
>
>      # tc filter add ... {u32|fw|tcindex|route|...} ... action ...
>
> When these actions get configured the specific actions tc_action_ops
> will be used to init the action create the hash 'tcf_hash_create' and
> parse the options. All this I can follow in ./net/sched/
>
> But the actions netlink hook does this,
>
> tc_ctl_action()
>      tcf_action_add()
>          tcf_action_init() <- inserts action in the table
>
> So at this point we have the entry in the table but I must be missing
> where the tc_action_ops act() is going to be called because its not via
> tcf_exts_exec().
>


There are two ways to add actions.
a) you specify a filter followed by a graph of actions to be executed
on a match (yes, in the kernel 10 years before Openflow and still
expressively more powerful;->)

b) You can add actions first, then later specify the filter followed by
a graph of actions. Actions in such a case are referenced by their
table indices.

#a tends to be more popular way of provisioning.

> Am I missing something obvious here? Is there a way to link them to
> filters? Sorry if it turns out to be a stupid question.
>

I think the second use case is what you are bumping into. I know from
answering questions this is a very popular use case in some eastern
European countries (where one policer with a specific rate is shared
by many flows); i think they have a setup where you share your DSL
connection with your neighbors. Its quiet a clever setup.


> My motivation here is to use the filters/actions outside the qdisc lock
> for mq, mqprio, and the ingress qdisc.
>

Are you trying to offload these actions into hardware?
Is the classifier in hardware?
Please let me know if you need further help. Example, I could send you
a bunch of examples for either

cheers,
jamal


> .John
>
