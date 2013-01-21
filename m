From: Li Yu <raise.sail@gmail.com>
Subject: Re: v3 for tcp friends?
Date: Mon, 21 Jan 2013 15:31:17 +0800
Message-ID: <50FCEEC5.9010404@gmail.com>
References: <20120903.154833.1547153833820955116.davem@davemloft.net> <CAEkNxbGJ6OGy3HDSeToXO_cDt7azpRZvy_CbQH0_UJ_mCS2s3w@mail.gmail.com> <20120904.125841.2293649688957878987.davem@davemloft.net> <50FCEE64.80203@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: brutus@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f51.google.com ([209.85.210.51]:64162 "EHLO
	mail-da0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699Ab3AUHb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 02:31:26 -0500
Received: by mail-da0-f51.google.com with SMTP id i30so2564514dad.38
        for <netdev@vger.kernel.org>; Sun, 20 Jan 2013 23:31:26 -0800 (PST)
In-Reply-To: <50FCEE64.80203@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B401=E6=9C=8821=E6=97=A5 15:29, Li Yu =E5=86=99=E9=
=81=93:
> =E4=BA=8E 2012=E5=B9=B409=E6=9C=8805=E6=97=A5 00:58, David Miller =E5=
=86=99=E9=81=93:
>> From: Bruce Curtis <brutus@google.com>
>> Date: Tue, 4 Sep 2012 08:10:23 -0700
>>
>>> Will do, issues addressed, I'll get the patch out later today or
>>> tomorrow at the latest.
>>
>> Thanks a lot Bruce.
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
>
> Hi, Bruce,
>
>      I tested the TCP friends, found a bug here:
>
> [  106.541372] Pid: 1765, comm: client Not tainted 3.7.0-rc1+ #25
> [  106.543121] Call Trace:
> [  106.543950]  [<ffffffff8133d212>] inet_sock_destruct+0x102/0x1f0
> [  106.545687]  [<ffffffff812c38ad>] __sk_free+0x1d/0x110
> [  106.547209]  [<ffffffff812c3a1c>] sk_free+0x1c/0x20
> [  106.548611]  [<ffffffff8131680c>] tcp_close+0x6c/0x3f0
> [  106.549863]  [<ffffffff8133caea>] inet_release+0xda/0xf0
> [  106.551134]  [<ffffffff8133ca30>] ? inet_release+0x20/0xf0
> [  106.552419]  [<ffffffff8137f3de>] ? mutex_unlock+0xe/0x10
> [  106.553658]  [<ffffffff812bf948>] sock_release+0x28/0xa0
> [  106.557366]  [<ffffffff812bfd69>] sock_close+0x29/0x30
> [  106.558831]  [<ffffffff81128972>] __fput+0x122/0x210
> [  106.560541]  [<ffffffff81128a6e>] ____fput+0xe/0x10
> [  106.562006]  [<ffffffff8105354e>] task_work_run+0x9e/0xd0
> [  106.563285]  [<ffffffff810027e1>] do_notify_resume+0x61/0x70
> [  106.564582]  [<ffffffff8138a908>] int_signal+0x12/0x17
>
>
>      I also backported and tested it on stable kernel 3.7.3/RHEL6
> kernel, this bug still exists. It seem that client may close listenin=
g
> sockets, may we need to add one reference count for listen socket
> before send its address to peer?
>

Sorry, I lost an important line of kernel log before above them:

[  106.539367] IPv4: Attempt to release TCP socket in state 10=20
ffff880074abb5c0

BTW: state 10 =3D TCP_LISTEN

>      And, our TCP friends v4? :)
>
>      Thanks
>
> Yu
>
