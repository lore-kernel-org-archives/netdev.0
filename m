From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [PATCH next-net] ipv6: Use hlist_for_each_entry_rcu_bh() in ipv6_chk_same_addr()
Date: Tue, 1 Nov 2011 16:33:49 +0800
Message-ID: <CAJFZqHxTh4kxaqiKWNGuu7vV_VvMx8jH-qXBr+dj7YNOitDrpQ@mail.gmail.com>
References: <1320125455-25222-1-git-send-email-roy.qing.li@gmail.com>
	<20111101.035323.458528114788135444.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:33660 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752330Ab1KAIdu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 04:33:50 -0400
Received: by gyb13 with SMTP id 13so6797721gyb.19
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2011 01:33:50 -0700 (PDT)
In-Reply-To: <20111101.035323.458528114788135444.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/11/1 David Miller <davem@davemloft.net>:
> From: roy.qing.li@gmail.com
> Date: Tue, =A01 Nov 2011 13:30:55 +0800
>
>> From: RongQing.Li <roy.qing.li@gmail.com>
>>
>> Replace hlist_for_each_entry and hlist_for_each_entry_rcu with
>> hlist_for_each_entry_rcu_bh() in ipv6_chk_same_addr and
>> ipv6_chk_addr to keep that all dereference methods for addr_list
>> are same, and take advantage of _rcu_bh() critical section
>> checking and prevention from compiler merging or refetching.
>>
>> Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
>
> Callers are already in an RCU section with BH disabled when these
> functions are invoked.
>

Yes, But I think the code readable is not good,
sometime, call hlist_for_each_entry, sometime
hlist_for_each_entry_rcu, sometime hlist_for_each_entry_rcu_bh.

I think the RCU pair should be :

rcu_read_lock_bh
 hlist_for_each_entry_rcu_bh(...)
rcu_read_unlock_bh

at the same time,   hlist_for_each_entry can not prevent compiler from
merging or refetching.

-Roy
