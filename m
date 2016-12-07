From: Gao Feng <fgao@ikuai8.com>
Subject: Re: [PATCH net-next v2 1/1] driver: ipvlan: Free ipvl_port directly
 with kfree instead of kfree_rcu
Date: Wed, 7 Dec 2016 08:35:35 +0800
Message-ID: <CA+6hz4pTrPQezJXQsR_-QNLF8FQqtrBDieX-3=znTBDQ4AO-JA@mail.gmail.com>
References: <1481032489-7864-1-git-send-email-fgao@ikuai8.com> <1481037510.18162.583.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbgsg2.qq.com ([54.254.200.128]:60871 "EHLO smtpbgsg2.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751998AbcLGAhe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Dec 2016 19:37:34 -0500
Received: from mail-ua0-f177.google.com (unknown [209.85.217.177])
        by esmtp4.qq.com (ESMTP) with SMTP id 0
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 08:35:36 +0800 (CST)
Received: by mail-ua0-f177.google.com with SMTP id 20so399800087uak.0
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 16:35:37 -0800 (PST)
In-Reply-To: <1481037510.18162.583.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Tue, Dec 6, 2016 at 11:18 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2016-12-06 at 21:54 +0800, fgao@ikuai8.com wrote:
>> From: Gao Feng <gfree.wind@gmail.com>
>>
>> There is no one which may reference the ipvlan port when free it in
>> ipvlan_port_create and ipvlan_port_destroy. So it is unnecessary to
>> use kfree_rcu.
>
> You did not really explain _why_ it was safe/unnecessary.
> Why should anyone trust you ?

Thanks your point.
I found the reason yesterday after receive your suggestion and reply
the last v1 email.
Then I send the v2 patch.
I assume the reviewer would know more than me, so I didn't add more details.

I will add more details in v3 patch.

>
> The reason an RCU grace period is not needed is that
> netdev_rx_handler_unregister() already enforces a grace period.
>
> My guess is ipvlan copied code in macvlan.
>
> At the time macvlan was written, commit
> 00cfec37484761a44 ("net: add a synchronize_net() in
> netdev_rx_handler_unregister()") was not there yet.
>
> macvlan could be changed the same way.

Yes. After I find the netdev_rx_handler_unregister which enforces one
grace period.
I prepare to check other codes.

Best Regards
Feng

>
>
>
