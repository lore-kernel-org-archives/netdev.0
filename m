From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: RFC: bring UP 'lo' by default after creating new netns
Date: Thu, 29 Jun 2017 23:26:46 -0700
Message-ID: <CAF2d9jg1P2AVOJ+FT+pRGjG0HW1YCRN9+WQ7xK67banby7EMng@mail.gmail.com>
References: <CAF2d9jhTcVgLHs_iqw+RRS=WhMtRF0ra5SygGMymuYQUW6HP0A@mail.gmail.com>
 <87efu22set.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Eric Dumazet <edumazet@google.com>, adobriyan@gmail.com,
        David Miller <davem@davemloft.net>, xiyou.wangcong@gmail.com,
        linux-netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:36582 "EHLO
        mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751494AbdF3G1I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 02:27:08 -0400
Received: by mail-it0-f47.google.com with SMTP id m68so56624466ith.1
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 23:27:07 -0700 (PDT)
In-Reply-To: <87efu22set.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 29, 2017 at 6:08 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> "Mahesh Bandewar (=E0=A4=AE=E0=A4=B9=E0=A5=87=E0=A4=B6 =E0=A4=AC=E0=A4=82=
=E0=A4=A1=E0=A5=87=E0=A4=B5=E0=A4=BE=E0=A4=B0)" <maheshb@google.com> writes=
:
>
>> Creation of new network namespace is almost always followed up by
>> bringing up the loopback device.
>>
>>         ip netns add foo
>>         ip -netns foo link set lo up
>>
>> I'm not sure if there are any consequences of bringing the device UP
>> at the creation of network-namespace.jjh
>
> Hard coded in net/core/net_namespace.c:copy_net_ns is definitely the
> wrong place in the code for something like this.  If this lives anywhere
> it should live in driver/net/loopback.c, or possibly in
> net/core/dev.c:net_dev_init.
>
interestingly dev_open() needs RTNL while it's not recommended at
net_dev_init() time.
Also net_dev_init() is called at the sub-system registration, do you
mean loopback_net_init() time?

> If we want this we want to match what we do when we the primary network
> namespace.  Just so that there are no unneeded surprises with network
> namespaces.
>
Yes, correct, it should be same whether it's init-net or some other. I
can add the IFF_UP flag during
loopback_setup() but then it will not perform anything that is done
during dev_open() phase. I'll try
moving the code to loopback_net_init() to achieve the same result so
that I can avoid that hard-coding too.

Thanks for comments Eric.

--mahesh..

> Eric
