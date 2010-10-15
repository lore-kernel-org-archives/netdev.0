From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: large divisor for flow classifier
Date: Fri, 15 Oct 2010 23:10:25 +0200
Message-ID: <4CB8C341.40000@gmail.com>
References: <4CB899F7.0@navigue.com> <1287172905.2799.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jonathan Thibault <jonathan@navigue.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:64937 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932539Ab0JOVKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 17:10:30 -0400
Received: by ewy20 with SMTP id 20so1610325ewy.19
        for <netdev@vger.kernel.org>; Fri, 15 Oct 2010 14:10:29 -0700 (PDT)
In-Reply-To: <1287172905.2799.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le vendredi 15 octobre 2010 =C3=A0 14:14 -0400, Jonathan Thibault a =C3=
=A9crit :
>> It appears that when setting a fairly large divisor on the flow clas=
sifier for sfq, traffic stops altogether.
>>
>> On my machine, anything above divisor 2200 seems to stop all traffic=
=2E  If I want to be fair between hosts (but not flows) for a large net=
work (say 6000 hosts), I run into problems.  Obviously the rates here a=
re quite low but this is just an example.
=2E..
> SFQ is limited to a 1024 divisor
>=20
> You might try following patch :
>=20
> (8192 is the smallest power of two greater than 6144)
>=20
> sizeof(struct sfq_sched_data) becomes 0x2ccc instead of 0x10cc
>=20
> keep in mind hash distribution is not perfect.
>=20
> What would be the real rate ?
>=20
>=20
> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
> index 3cf478d..c4a53d6 100644
> --- a/net/sched/sch_sfq.c
> +++ b/net/sched/sch_sfq.c
> @@ -77,7 +77,7 @@
>  	It is easy to increase these values, but not in flight.  */
> =20
>  #define SFQ_DEPTH		128
> -#define SFQ_HASH_DIVISOR	1024
> +#define SFQ_HASH_DIVISOR	8192

Because of low SFQ_DEPTH, which limits its queue to 127 packets,
SFQ isn't suitable for serving so many users. There is sch_drr as
a replacement, alas more complex and undocumented, but google should
help you enough.

http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commit;h=3D13d2a1d2b032de08d7dcab6a1edcd47802681f96

Jarek P.
