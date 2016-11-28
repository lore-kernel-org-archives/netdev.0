From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH] mlx4: give precise rx/tx bytes/packets counters
Date: Mon, 28 Nov 2016 23:55:25 +0200
Message-ID: <CALzJLG8qjz7Qx8rWbthtJ1uJt2c8w_1gMeRkmB+SZ+xv2Eu3EQ@mail.gmail.com>
References: <1480088780.8455.543.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG8nFBFy=-pjy-XBYb-y-F=grC5wjN35zTt9eUOT-612Eg@mail.gmail.com>
 <1480212960.18162.23.camel@edumazet-glaptop3.roam.corp.google.com> <20161128.154057.1355209532933900181.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:35351 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755724AbcK1Vzt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 16:55:49 -0500
Received: by mail-lf0-f67.google.com with SMTP id p100so10844100lfg.2
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 13:55:46 -0800 (PST)
In-Reply-To: <20161128.154057.1355209532933900181.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 10:40 PM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sat, 26 Nov 2016 18:16:00 -0800
>
>> On Sun, 2016-11-27 at 00:47 +0200, Saeed Mahameed wrote:
>>> On Fri, Nov 25, 2016 at 5:46 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>
>>> As you see here in SRIOV mode (PF only) reads   sw stats from FW.
>>> Tariq, I think we need to fix this.
>>
>> Sure, my patch does not change this at all.
>>
>> If mlx4_is_master() is false, then we aggregate the software states and
>> only the software stats.
>>
>> My patch makes this aggregation possible at the time ethtool or
>> ndo_get_stat64() are called, since this absolutely not depend on the 250
>> ms timer fetching hardware stats.
>
> Saeed please provide counter arguments or ACK this patch, thank you.

I have nothing against this patch, I just wanted to point out that
this patch is just fixing the symptom.
We keep ignoring the root cause that dev_get_stats is called under a
spin_lock which really ties our hands "us device drivers developers"
and push us towards those fragile solutions like deferred work for
caching statistics.
I am not saying that Eric should fix this in his patch, i just wanted
to raise the awareness of the root cause.

Regarding the SRIOV PF stats, i will take it with Tariq internally.

Bottom line, I ACK this patch, I might even do the same myself for
mlx5 :), but there are some follow ups that need to be done.
