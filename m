From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net] ipv6: fix rtnl lock assertion failure in ipv6_sock_ac_join()
Date: Tue, 2 Sep 2014 16:29:14 -0700
Message-ID: <CAHA+R7MFz10YGTR8hD=N0s9FBD5N=p+Qu3_F0GJO0Tv-4STu+A@mail.gmail.com>
References: <1409681239-4852-1-git-send-email-xiyou.wangcong@gmail.com>
	<1409693381.15984.19.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Sabrina Dubroca <sd@queasysnail.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:38126 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750787AbaIBX3P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 19:29:15 -0400
Received: by mail-lb0-f181.google.com with SMTP id s7so201008lbd.12
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 16:29:14 -0700 (PDT)
In-Reply-To: <1409693381.15984.19.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 2, 2014 at 2:29 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Hi Cong,
>
> On Di, 2014-09-02 at 11:07 -0700, Cong Wang wrote:
>> @@ -198,7 +198,7 @@ void ipv6_sock_ac_close(struct sock *sk)
>>       spin_unlock_bh(&ipv6_sk_ac_lock);
>>
>>       prev_index = 0;
>> -     rcu_read_lock();
>> +     rtnl_lock();
>>       while (pac) {
>>               struct ipv6_ac_socklist *next = pac->acl_next;
>>
>> @@ -211,7 +211,7 @@ void ipv6_sock_ac_close(struct sock *sk)
>>               sock_kfree_s(sk, pac, sizeof(*pac));
>>               pac = next;
>>       }
>> -     rcu_read_unlock();
>> +     rtnl_unlock();
>>  }
>>
>
> Nit:
> You forgot to convert a dev_get_by_index_rcu to __dev_get_by_index in
> ipv6_sock_ac_close.
>

Good catch! Will update this patch together with "Fixes:" tag.

Thanks.
