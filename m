From: Patrick McHardy <kaber@trash.net>
Subject: Re: tc related lockdep warning.
Date: Mon, 25 Sep 2006 15:29:10 +0200
Message-ID: <4517D9A6.70307@trash.net>
References: <20060925124352.GA1592@ff.dom.local> <1159188473.5301.68.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@o2.pl>, netdev@vger.kernel.org,
	Dave Jones <davej@redhat.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:5260 "EHLO stinky.trash.net")
	by vger.kernel.org with ESMTP id S1751155AbWIYN3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 09:29:14 -0400
To: hadi@cyberus.ca
In-Reply-To: <1159188473.5301.68.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Mon, 2006-25-09 at 14:43 +0200, Jarek Poplawski wrote:
> 
> 
>>It's probably 2.6.18 and should change a little now (git4) but
>>IMHO main problem stays: it looks tcf_act_police_locate in
>>act_police.c was preempted in read_lock (tcf_police_lookup)
>>- now the same is possible in tcf_hash_lookup. So maybe
>>read_lock_bh will help?
>>
> 
> 
> Yes, that looks plausible. Can you try making those changes and see if
> the warning is gone?


I think this points to a bigger brokeness caused by the move of
dev->qdisc to RCU. It means destruction of filters and actions doesn't
necessarily happens in user-context and thus not protected by the rtnl
anymore. On first sight all actions are affected by this, as well as
the u32 classifier (race between u32_destroy and u32_init while changing
u32_list), but I bet there are more. I'm busy right now, but I'll look
into this later.

