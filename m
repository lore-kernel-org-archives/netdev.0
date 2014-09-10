From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v3 09/15] net: sched: make cls_u32 lockless
Date: Tue, 09 Sep 2014 21:53:40 -0700
Message-ID: <540FD954.5000704@gmail.com>
References: <20140909055221.2071.99671.stgit@nitbit.x32> <20140909055815.2071.39668.stgit@nitbit.x32> <CAHA+R7NLq26v6K5j01WMjVd-NB9=3peUs1d-QPgfP0=MpU+Pug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev <netdev@vger.kernel.org>,
	Paul McKenney <paulmck@linux.vnet.ibm.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:62381 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784AbaIJEyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 00:54:01 -0400
Received: by mail-oa0-f46.google.com with SMTP id eb12so3629460oac.33
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 21:54:00 -0700 (PDT)
In-Reply-To: <CAHA+R7NLq26v6K5j01WMjVd-NB9=3peUs1d-QPgfP0=MpU+Pug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/09/2014 11:02 AM, Cong Wang wrote:
> On Mon, Sep 8, 2014 at 10:58 PM, John Fastabend
> <john.fastabend@gmail.com> wrote:
>>
>> +void __u32_delete_key(struct rcu_head *rcu)
>> +{
>> +       struct tc_u_knode *key = container_of(rcu, struct tc_u_knode, rcu);
>> +
>> +       u32_destroy_key(key->tp, key);
>> +}
>
> This can become static?
>

Yep thanks and I changed the name to u32_delete_key_rcu().

-- 
John Fastabend         Intel Corporation
