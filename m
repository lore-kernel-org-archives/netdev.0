From: =?UTF-8?B?0JzQsNGA0Log0JrQvtGA0LXQvdCx0LXRgNCz?=
	<socketpair@gmail.com>
Subject: Re: Simple kernel attack using socketpair. easy, 100% reproductiblle,
 works under guest. no way to protect :(
Date: Thu, 25 Nov 2010 13:05:26 +0500
Message-ID: <AANLkTi=18wQEU+UpdmGDBM8H13biGLMEyRPKaGuzdi7p@mail.gmail.com>
References: <AANLkTikCeddPFRGojPGuB6oq3xGYgovtm8r4=WhjEDpe@mail.gmail.com>
	<1290666501.2798.84.camel@edumazet-laptop>
	<AANLkTik8Fxmd-KwGw498fMyONfVNteFcfCmz+9-V_QZh@mail.gmail.com>
	<1290668246.2798.93.camel@edumazet-laptop>
	<AANLkTinRhmiVoVR5ibWOKe-OhY4fYUs_PHSATjxMGqg9@mail.gmail.com>
	<1290670889.2798.127.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:35493 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153Ab0KYIF1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 03:05:27 -0500
Received: by bwz15 with SMTP id 15so615606bwz.19
        for <netdev@vger.kernel.org>; Thu, 25 Nov 2010 00:05:26 -0800 (PST)
In-Reply-To: <1290670889.2798.127.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/11/25 Eric Dumazet <eric.dumazet@gmail.com>:
> Le jeudi 25 novembre 2010 =C3=A0 12:35 +0500, =D0=9C=D0=B0=D1=80=D0=BA=
 =D0=9A=D0=BE=D1=80=D0=B5=D0=BD=D0=B1=D0=B5=D1=80=D0=B3 a =C3=A9crit :
>> 2010/11/25 Eric Dumazet <eric.dumazet@gmail.com>:
>> > Le jeudi 25 novembre 2010 =C3=A0 11:52 +0500, =D0=9C=D0=B0=D1=80=D0=
=BA =D0=9A=D0=BE=D1=80=D0=B5=D0=BD=D0=B1=D0=B5=D1=80=D0=B3 a =C3=A9crit=
 :
>> >> Well, It seems, that patch likely will fix 100% CPU usage.
>> >>
>> >> But what about eating all available descriptors in kernel ? vulne=
rability ?
>> >>
>> >
>> > It doesnt fix cpu usage actually, your program eats 100% of one cp=
u,
>> > like the following one :
>> >
>> > for (;;) ;
>>
>> No. You don't understand. I can't kill -KILL such program. CPU usage
>> will be 100%. program hang in kernel, process is not in
>> Uninterruptible sleep (in Running state). So I think some kernel loo=
p
>> like for(;;); exists. maybe looped recursion or so on.
>>
>
> I understand very well, thanks.
>
> There is no recursion (stack usage) in kernel, this is why CPU eats s=
o
> much cycles to handle your workload.
>
> kill ... is not interrupting this loop in kernel, only when current
> system call is finished.
>
> We'll have to add limits to forbid malicious programs to use too much
> cpu in kernel.

new ulimit constant ?
how to detect, that user is malicious ?
I think, it will be nice to count "reursion level" of file descriptors
instances.
recursion level increases if fd is put inside unix socket.
If recursion level is bigger than some border (10 for example), do not
to allow to put such file descriptor into unixsocket.
I understand .. this is heavy.

=46ortunatelly I have idea :) :
Do not allow to pass unix socket A into unixsocket B if A contains
file descriptors. I think it would not break current applications.
This will fix problem which illustrate my example.
But, malicious user can insert descriptors into A _AFTER_ passing A
into B, by using another A instance called C. Kernel should not allow
do that -- if kernel see, that unix socket A=3DC already inside some
other unix socket, it should return error.


--=20
Segmentation fault
