From: Tomas Papan <tomas.papan@gmail.com>
Subject: Re: e1000e: possible reggresion?
Date: Fri, 21 Aug 2015 12:48:42 +0200
Message-ID: <CAMGsXDQa=NR3qUd4xJpSNcS2myF+n9P_A-zvyKQYjjE5XN2zCA@mail.gmail.com>
References: <665F7BF9-6041-4E7D-8A37-1B87770F9FAA@gmail.com>
	<1440102551.6610.65.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:34081 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752624AbbHUKsm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 06:48:42 -0400
Received: by iodb91 with SMTP id b91so76854428iod.1
        for <netdev@vger.kernel.org>; Fri, 21 Aug 2015 03:48:42 -0700 (PDT)
In-Reply-To: <1440102551.6610.65.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

It was probalby it. Uptime 5+ hours and no problem.

Thanks for the hint, I was compiling linus tree yesterday around 12:00 =
UTC,
your change was added later.

Regards
Tomas

On Thu, Aug 20, 2015 at 10:29 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> On Thu, 2015-08-20 at 21:37 +0200, Tomas Papan wrote:
>> Hi there,
>>
>> I=E2=80=99m observing a freeze with the recent kernel (4.2-rc7). Unf=
ortunately I can=E2=80=99t preserver the full traces.
>> There is nothing in the messages after reboot, I was just lucky one =
time to see it when tail -f /var/log/messages was running.
>> This is the only line which I was able to get:
>>       eth1 (e1000e): transmit queue 0 timed out
>>
>> I=E2=80=99ve got this message in the past, but the ethtool -K eth1 t=
so off solved that. I=E2=80=99m always running
>> this command at the boot time since then. There is no issue with 4.2=
-rc4. It is hard to bisect,
>> because this machine is used as headless server and it happens rando=
mly (usually within 2 hours).
>>
>> Do you have any idea how to trace it or what can I do?
>> Please keep me on CC since I=E2=80=99m not subscribed on this list
>>
>> Regards
>> Tomas
>
> I would pull latest tree from Linus and pray the bug was fixed.
>
> My feeling is that you hit the issue fixed with
>
> commit 83fccfc3940c4a2db90fd7e7079f5b465cd8c6af
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Thu Aug 13 15:44:51 2015 -0700
>
>     inet: fix potential deadlock in reqsk_queue_unlink()
>
>     When replacing del_timer() with del_timer_sync(), I introduced
>     a deadlock condition :
>
>     reqsk_queue_unlink() is called from inet_csk_reqsk_queue_drop()
>
>     inet_csk_reqsk_queue_drop() can be called from many contexts,
>     one being the timer handler itself (reqsk_timer_handler()).
>
>     In this case, del_timer_sync() loops forever.
>
>     Simple fix is to test if timer is pending.
>
>     Fixes: 2235f2ac75fd ("inet: fix races with reqsk timers")
>     Signed-off-by: Eric Dumazet <edumazet@google.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
>
