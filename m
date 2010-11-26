From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: Fwd: Simple kernel attack using socketpair. easy, 100% reproductiblle,
 works under guest. no way to protect :(
Date: Fri, 26 Nov 2010 15:52:43 +0800
Message-ID: <4CEF674B.1070504@cn.fujitsu.com>
References: <AANLkTikCeddPFRGojPGuB6oq3xGYgovtm8r4=WhjEDpe@mail.gmail.com>	 <1290666501.2798.84.camel@edumazet-laptop>	 <AANLkTik8Fxmd-KwGw498fMyONfVNteFcfCmz+9-V_QZh@mail.gmail.com>	 <1290668246.2798.93.camel@edumazet-laptop>	 <AANLkTinQa8BCH-k0m=ndu4u8L-kCiD00jYjKvsvoxK2E@mail.gmail.com>	 <AANLkTin3SAdiRR4eda3SDdDV4XfKTqH5Z0a7Pih2O4jZ@mail.gmail.com>	 <1290672978.2798.151.camel@edumazet-laptop>	 <AANLkTi=NTFXXY42nh+j3xM4n-NTPaz=fWKmAY=MpsHze@mail.gmail.com>	 <1290694299.2858.330.camel@edumazet-laptop>	 <4CEF39AF.6090605@cn.fujitsu.com> <1290752611.2678.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?0JzQsNGA0Log0JrQvtGA0LXQvdCx0LXRgNCz?=
	<socketpair@gmail.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63084 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753355Ab0KZHy2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Nov 2010 02:54:28 -0500
In-Reply-To: <1290752611.2678.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote, at 11/26/2010 02:23 PM:
> Le vendredi 26 novembre 2010 =C3=A0 12:38 +0800, Shan Wei a =C3=A9cri=
t :
>> Eric Dumazet wrote, at 11/25/2010 10:11 PM:
>>> Le jeudi 25 novembre 2010 =C3=A0 13:35 +0500, =D0=9C=D0=B0=D1=80=D0=
=BA =D0=9A=D0=BE=D1=80=D0=B5=D0=BD=D0=B1=D0=B5=D1=80=D0=B3 a =C3=A9crit=
 :
>>>> quick and dirty fix will be not to allow to pass unix socket insid=
e
>>>> unix socket. I think it would not break much applications.
>>>
>>> Really, if it was not needed, net/unix/garbage.c would not exist at
>>> all...
>>>
>>> It is needed by some apps.
>>>
>>>
>>> [PATCH] af_unix: limit recursion level
>>>
>>> Its easy to eat all kernel memory and trigger NMI watchdog, using a=
n
>>> exploit program that queues unix sockets on top of others.
>>>
>>> lkml ref : http://lkml.org/lkml/2010/11/25/8
>>>
>>> This mechanism is used in applications, one choice we have is to ha=
ve a
>>> recursion limit.
>>>
>>> Other limits might be needed as well (if we queue other types of fi=
les),
>>> since the passfd mechanism is currently limited by socket receive q=
ueue
>>> sizes only.
>>>
>>> Add a recursion_level to unix socket, allowing up to 4 levels.
>>>
>>> Each time we send an unix socket through sendfd mechanism, we copy =
its
>>> recursion level (plus one) to receiver. This recursion level is cle=
ared
>>> when socket receive queue is emptied.
>>>
>>> Reported-by: =D0=9C=D0=B0=D1=80=D0=BA =D0=9A=D0=BE=D1=80=D0=B5=D0=BD=
=D0=B1=D0=B5=D1=80=D0=B3 <socketpair@gmail.com>
>>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>>
>> This problem is same as that reported with title "Unix socket local =
DOS (OOM)", right?
>> After applied this patch, this program can be killed now. but still =
eat 100% cpu.=20
>>
>=20
> Not the same problem, but a different one.=20
>=20
> In this case, we queue files on top of another and never give a chanc=
e
> to free them, unless the program dies (and full memory eaten)
>=20
> And yes, its eating 100% cpu, since it has no sleep inside, like
>=20
> for (;;) ;

Got it. Thanks.

Have a out of topic question.=20
There is some difficulty for me to understand this issue. :-(
why can't we kill this program?

When send fd[0] to ff[0] socket, fd[0] is in flight and will be add ref=
erence value.
Athough we close fd[0], their references is still exist.

The reason that can't be killed is about the references or about the la=
test sockets
created by socketpair() but never be freeed.

--=20
Best Regards
-----
Shan Wei
