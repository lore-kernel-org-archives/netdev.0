From: Eric Dumazet <edumazet@google.com>
Subject: Re: [scr265482] ip_tunnel.c
Date: Thu, 24 Nov 2016 20:15:16 -0800
Message-ID: <CANn89iKDfndPr3KTwph3TTQF3V+3E_RhwUuHg1JtOHhG1ExtAg@mail.gmail.com>
References: <F41877A268BCDE49BAEE2286FA8C269F6FECFD83@LETV-MBX-IDC09.letv.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?UTF-8?B?TGl5YW5nIFl1ICjkuo7nq4vmtIsxKQ==?= <yuliyang1@le.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:36705 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752344AbcKYEPS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 23:15:18 -0500
Received: by mail-io0-f180.google.com with SMTP id x94so107321021ioi.3
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2016 20:15:17 -0800 (PST)
In-Reply-To: <F41877A268BCDE49BAEE2286FA8C269F6FECFD83@LETV-MBX-IDC09.letv.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 24, 2016 at 7:52 PM, Liyang Yu (=E4=BA=8E=E7=AB=8B=E6=B4=8B1) <=
yuliyang1@le.com> wrote:
>  I accept that the issue is not a CVE candidate. But it's a bug isn't it


Bug is in the RFC for not describing how both ends would magically synchron=
ize,
with a sequence protocol which is unidirectional, with no ACK packets
or whatever going back.

With no description, it means that RFC author(s) never considered one
side of the tunnel could die and restart.

Contact the author(s) to get his thoughts maybe ?

>
>  Thank you for your suggestions, about the format of mail, and not next t=
ime.
>
>  Everything has its meaning. If sequence number is a joke, why the guys p=
ut it into RFC , even implemented the feature.

You will learn that not everything put in RFC or other piece of paper
makes sense.
And the implementation is exactly implementing the RFC bug, because, why no=
t ?

Now if you believe you can make this work, please send patches.


>
>  And if you means that SMP ( Symmetric Multi Processing )?

Yes.

If you enable sequences, GRE performance is abysmal on SMP,
 because linux uses an extra lock, instead of allowing multiple cpus
using GRE tunnel at the same time,
and GSO/TSO are disabled .



>
>
>
> On Thu, Nov 24, 2016 at 5:39 PM, Liyang Yu (=E4=BA=8E=E7=AB=8B=E6=B4=8B1)=
 <yuliyang1@le.com> wrote:
>>
>>
>>
>>
>>
>>
>>
>> BTW:
>>
>>    Which RFC suggests UINT_MAX as GRE sequence number?  Can you show me?
>>
>>
>>
>>
>>
>>
>
>
> RFC 2890
>
> In any cases, this is absolutely not a security issue nor a CVE candidate=
.
> Please remove security@kernel.org from CC, no need to spam security guys,=
 they have enough on their plate.
>
> Please send text messages, no HTML is allowed on netdev
>
> Nobody sane uses GRE sequence numbers, precisely because GRE has no docum=
ented way to synchronize the source and destination of the tunnel.
> Basically, if you use GRE sequence numbers, you must re-start other side =
of the tunnel if one side had to restart, or risk dropping up to 2^31 packe=
ts.
>
> Really, this is not something that can be solved by using 'a different in=
itial sequence number'
>
> linux GRE sequence number support is a joke, it does not support SMP for =
a start.
>
>
>
>>
>>
>>
>> On Wed, Nov 23, 2016 at 11:45 PM, Liyang Yu (=E4=BA=8E=E7=AB=8B=E6=B4=8B=
1) <yuliyang1@le.com> wrote:
>>
>> > Yeah=EF=BC=8CI means that recreate the tunnel again, But I don=E2=80=
=99t think the
>>
>> > patch can fix the bug. It only can make the first packet received succ=
essed. And the follow packet will droped also.
>>
>> > In function __gre_xmit  line 366
>>
>> >   tunnel->o_seqno++;
>>
>> >
>>
>> > If you restart from UINT_MAX, the 'o_seqno' of second packet will retu=
rn to 0 again.
>>
>>
>>
>> The first packet after restart: o_seqno =3D=3D UINT_MAX, the other end:
>> i_seqno =3D 0 The second packet after restart: o_seqno =3D=3D 0, the oth=
er
>> end: i_seqno =3D 1
>>
>>
>>
>> So traffic should be back to normal.
>>
>>
>>
>> UINT_MAX is also what RFC suggests.
