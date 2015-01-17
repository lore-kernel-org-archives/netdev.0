From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 2/2] net: replace br_fdb_external_learn_*
 calls with switchdev notifier events
Date: Sat, 17 Jan 2015 15:28:36 -0500 (EST)
Message-ID: <20150117.152836.1278279020949227202.davem@davemloft.net>
References: <1421362177-10719-2-git-send-email-jiri@resnulli.us>
	<CAE4R7bAXvxFzuvuz5YPviTDsMLCYWnQxbkHkVJbjYq6+K574rw@mail.gmail.com>
	<20150117083112.GB1891@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, netdev@vger.kernel.org, jhs@mojatatu.com,
	sfeldma@gmail.co, stephen@networkplumber.org,
	linus.luessing@web.de, tgraf@suug.ch
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40229 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbbAQU2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jan 2015 15:28:41 -0500
In-Reply-To: <20150117083112.GB1891@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sat, 17 Jan 2015 09:31:12 +0100

>>> @@ -3026,11 +3026,17 @@ static void rocker_port_fdb_learn_work(struct work_struct *work)
>>>                 container_of(work, struct rocker_fdb_learn_work, work);
>>>         bool removing = (lw->flags & ROCKER_OP_FLAG_REMOVE);
>>>         bool learned = (lw->flags & ROCKER_OP_FLAG_LEARNED);
>>> +       struct netdev_switch_notifier_fdb_info info;
>>> +
>>> +       info.addr = lw->addr;
>>> +       info.vid = lw->vid;
>>
>>If you respin patch, use initializer to zero out other members, just
>>to future proof it.
> 
> There are no other members :)

That's why he said "future proof", he knows there are no other members
(currently) too.
