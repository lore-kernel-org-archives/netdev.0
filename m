From: John Fastabend <john.fastabend@gmail.com>
Subject: locating the 'tc actions' hook
Date: Wed, 31 Jul 2013 14:19:10 -0700
Message-ID: <51F97F4E.5070102@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	netdev <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:52629 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751418Ab3GaVT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 17:19:29 -0400
Received: by mail-ob0-f182.google.com with SMTP id wo10so2365661obc.41
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 14:19:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jamal,

I'm trying to sort out why I would use 'tc actions' and exactly
what it is doing.

Its clear I think adding one or more actions to filters will be
used in the classifier via tcf_exts_exec() through the classify
hook called from a qdisc.

This is your standard

	# tc filter add ... {u32|fw|tcindex|route|...} ... action ...

When these actions get configured the specific actions tc_action_ops
will be used to init the action create the hash 'tcf_hash_create' and
parse the options. All this I can follow in ./net/sched/

But the actions netlink hook does this,

tc_ctl_action()
	tcf_action_add()
		tcf_action_init() <- inserts action in the table

So at this point we have the entry in the table but I must be missing
where the tc_action_ops act() is going to be called because its not via
tcf_exts_exec().

Am I missing something obvious here? Is there a way to link them to
filters? Sorry if it turns out to be a stupid question.

My motivation here is to use the filters/actions outside the qdisc lock
for mq, mqprio, and the ingress qdisc.

.John

-- 
John Fastabend         Intel Corporation
