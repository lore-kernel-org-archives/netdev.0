From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v4 net-next 1/1] net_sched: Introduce skbmod action
Date: Mon, 12 Sep 2016 18:08:01 -0400
Message-ID: <9fa9ffe0-33f2-8421-4547-aaf7452b5c10@mojatatu.com>
References: <1473713206-2450-1-git-send-email-jhs@emojatatu.com>
 <1473717514.18970.80.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, daniel@iogearbox.net,
        john.r.fastabend@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:33230 "EHLO
        mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756164AbcILWIF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 18:08:05 -0400
Received: by mail-oi0-f53.google.com with SMTP id y2so339618574oie.0
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 15:08:04 -0700 (PDT)
In-Reply-To: <1473717514.18970.80.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-12 05:58 PM, Eric Dumazet wrote:
> On Mon, 2016-09-12 at 16:46 -0400, Jamal Hadi Salim wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
>> +
>> +	/* XXX: if you are going to edit more fields beyond ethernet header
>> +	 * (example when you add IP header replacement or vlan swap)
>> +	 * then MAX_EDIT_LEN needs to change appropriately
>> +	*/
>> +	err = skb_ensure_writable(skb, ETH_HLEN);
>> +	if (unlikely(err)) /* best policy is to drop on the floor */
>> +		action = TC_ACT_SHOT;
>> +
>> +	rcu_read_lock();
>> +	action = READ_ONCE(d->tcf_action);
>
> You are overwriting @action, while you might have put TC_ACT_SHOT in it
> 3 lines above.
>
> Maybe you meant :
> 	if (err)
> 		return TC_ACT_SHOT;
>

Thanks for catching that (leftover from when i used a lock).
Will resubmit.

cheers,
jamal
