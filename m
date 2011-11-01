From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [PATCH next-net] ipv6: Use hlist_for_each_entry_rcu_bh() in ipv6_chk_same_addr()
Date: Tue, 1 Nov 2011 17:17:23 +0800
Message-ID: <CAJFZqHz1xFHaOus_LgKZi5Pgb0gW-c9uLvqZtS69G6vmqy+OCg@mail.gmail.com>
References: <CAJFZqHxTh4kxaqiKWNGuu7vV_VvMx8jH-qXBr+dj7YNOitDrpQ@mail.gmail.com>
	<20111101.043938.1065811675133329291.davem@davemloft.net>
	<CAJFZqHwBwnNPBnPYqyUR8NU2LnagJtBEnvkzRL9TqrdQEqfhXA@mail.gmail.com>
	<20111101.050636.2188753893784711943.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:52409 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100Ab1KAJRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 05:17:24 -0400
Received: by ywf7 with SMTP id 7so2025055ywf.19
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2011 02:17:23 -0700 (PDT)
In-Reply-To: <20111101.050636.2188753893784711943.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/11/1 David Miller <davem@davemloft.net>:
> From: RongQing Li <roy.qing.li@gmail.com>
> Date: Tue, 1 Nov 2011 17:05:19 +0800
>
>> 2011/11/1 David Miller <davem@davemloft.net>:
>>> From: RongQing Li <roy.qing.li@gmail.com>
>>> Date: Tue, 1 Nov 2011 16:33:49 +0800
>>>
>>>> Yes, But I think the code readable is not good,
>>>
>>> It is wasteful to add multiple BH disables and RCU memory
>>> barriers in code paths where it is not necessary.
>>>
>>> Your patch fixes no real bug, and adds a regression.
>>>
>>
>> hlist_for_each_entry_rcu_bh() does not disable BH,
>> it only check If BH is disabled.
>>
>> These codes is different from normal RCU convention.
>
> But adding _rcu does add memory barriers.
>

Yes,  But I hope we can keep this convention.

Like the below similar codes, which exists in everywhere,
If we  replace rcu_dereference_bh with dereference ..
it is not good solution, though we can reduce  memory barriers

	rcu_read_lock_bh();

	txq = dev_pick_tx(dev, skb);
	q = rcu_dereference_bh(txq->qdisc);
