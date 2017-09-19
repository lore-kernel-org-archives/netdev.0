From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [REGRESSION] Warning in tcp_fastretrans_alert() of net/ipv4/tcp_input.c
Date: Tue, 19 Sep 2017 11:16:03 -0700
Message-ID: <CAK6E8=d599j+PU7FKEA4Ww5Lj28M6UwZs+Xqg-iDPwhNwkmhZw@mail.gmail.com>
References: <10035198.1vE6NFrMDO@natalenko.name> <40697505.YK5nrFG7Le@natalenko.name>
 <CAK6E8=djbT-35JuHq+hhOKOG+BEO3RCwgsVPoKcDhNBph5OezA@mail.gmail.com>
 <2149381.XGPd7soC9e@natalenko.name> <CAK6E8=e7SE-M4r2nJ8K_FoDMVcN2xYdtw=MetvD5MvXMm9iA1Q@mail.gmail.com>
 <13e86265b8db3a5b1f1eaf8135ff4510@natalenko.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Neal Cardwell <ncardwell@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Netdev <netdev@vger.kernel.org>
To: Oleksandr Natalenko <oleksandr@natalenko.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f170.google.com ([209.85.217.170]:50135 "EHLO
        mail-ua0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751370AbdISSQp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 14:16:45 -0400
Received: by mail-ua0-f170.google.com with SMTP id 97so283207uai.6
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 11:16:45 -0700 (PDT)
In-Reply-To: <13e86265b8db3a5b1f1eaf8135ff4510@natalenko.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 19, 2017 at 4:04 AM, Oleksandr Natalenko
<oleksandr@natalenko.name> wrote:
> Hi.
>
> 18.09.2017 23:40, Yuchung Cheng wrote:
>>
>> I assume this kernel does not have the patch that Neal proposed in his
>> first reply?
>
>
> Correct.
>
>> The main warning needs to be triggered by another peculiar SACK that
>> kicks the sender into recovery again (after undo). Please let it run
>> longer if possible to see if we can get both. But the new data does
>> indicate the we can (validly) be in CA_Open with retrans_out > 0.
>
>
> OK, here it is:
>
> =3D=3D=3D
> =C2=BB LC_TIME=3DC jctl -kb | grep RIP
> =E2=80=A6
> Sep 19 12:54:03 defiant kernel: RIP: 0010:tcp_undo_cwnd_reduction+0xbd/0x=
d0
> Sep 19 12:54:22 defiant kernel: RIP: 0010:tcp_undo_cwnd_reduction+0xbd/0x=
d0
> Sep 19 12:54:25 defiant kernel: RIP: 0010:tcp_undo_cwnd_reduction+0xbd/0x=
d0
> Sep 19 12:56:00 defiant kernel: RIP: 0010:tcp_fastretrans_alert+0x7c8/0x9=
90
> Sep 19 12:57:07 defiant kernel: RIP: 0010:tcp_undo_cwnd_reduction+0xbd/0x=
d0
> Sep 19 12:57:14 defiant kernel: RIP: 0010:tcp_undo_cwnd_reduction+0xbd/0x=
d0
> Sep 19 12:58:04 defiant kernel: RIP: 0010:tcp_undo_cwnd_reduction+0xbd/0x=
d0
> =E2=80=A6
> =3D=3D=3D
>
> Note timestamps =E2=80=94 two types of warning are distant in time, so di=
dn't happen
> at once.
>
> While still running this kernel, anything else I can check for you?
Thanks. Based on all the experiments you did I believe there's other
code path than my hypothesis that'd cause the warning:
1) Neal's proposed F-RTO fix didn't work
2) the main warning is not being triggered together with the newly-instrume=
nted
warning in undo
3) Disabling RACK stopped the warning

We couldn't figure out exactly what. So we'll do a bit code auditing
first to find more suspects
