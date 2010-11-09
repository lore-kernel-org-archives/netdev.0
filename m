From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: Re: Loopback performance from kernel 2.6.12 to 2.6.37
Date: Tue, 9 Nov 2010 11:05:37 +1100
Message-ID: <AANLkTi=HhouZymj0R7JsDy-X1LDbfT_WL0x10EMhdOho@mail.gmail.com>
References: <1288954189.28003.178.camel@firesoul.comx.local>
	<1288988955.2665.297.camel@edumazet-laptop>
	<1289213926.15004.19.camel@firesoul.comx.local>
	<1289214289.2820.188.camel@edumazet-laptop>
	<1289228785.2820.203.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <jdb@comx.dk>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52515 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753132Ab0KIAFj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 19:05:39 -0500
Received: by fxm16 with SMTP id 16so4552171fxm.19
        for <netdev@vger.kernel.org>; Mon, 08 Nov 2010 16:05:38 -0800 (PST)
In-Reply-To: <1289228785.2820.203.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

results on an i7 860 @ 2.80Ghz machine, no virtualization involved. 2.6=
=2E37-rc1+

# time dd if=3D/dev/zero bs=3D1M count=3D10000 | netcat  127.0.0.1 9999
10000+0 records in
10000+0 records out
10485760000 bytes (10 GB) copied, 50.2022 s, 209 MB/s

real	0m50.210s
user	0m1.094s
sys	0m57.589s



On Tue, Nov 9, 2010 at 2:06 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le lundi 08 novembre 2010 =E0 12:04 +0100, Eric Dumazet a =E9crit :
>> Le lundi 08 novembre 2010 =E0 11:58 +0100, Jesper Dangaard Brouer a
>> =E9crit :
>> > On Fri, 2010-11-05 at 21:29 +0100, Eric Dumazet wrote:
>> > > Le vendredi 05 novembre 2010 =E0 11:49 +0100, Jesper Dangaard Br=
ouer a
>> > > =E9crit :
>> > > > Hi Eric,
>> > > >
>> > > > A colleague send me a link to someone who has done some quite =
extensive
>> > > > performance measurements across different kernel versions.
>> > > >
>> > > > I noticed that the loopback performance has gotten quite bad:
>> > > >
>> > > > http://www.phoronix.com/scan.php?page=3Darticle&item=3Dlinux_2=
612_2637&num=3D6
>> > > >
>> > > > I though you might be interested in the link.
>> > > >
>> > > > See you around :-)
>> > >
>> > > Hi !
>> > >
>> > > Problem is : I have no idea what test they exactly use,
>> > > do you have info about it ?
>> >
>> > Its called the Phoronix test-suite, their website is:
>> > http://www.phoronix-test-suite.com/?k=3Dhome
>> >
>> > On my Ubuntu workstation their software comes as a software packag=
e:
>> > =A0sudo aptitude install phoronix-test-suite
>> >
>> > They seem to be related to the test/review site:
>> > http://www.phoronix.com/
>> >
>> >
>> >
>> > > This probably can be explained very fast.
>> >
>> > The loopback test seems to be the only real networking test they d=
o.
>> > It looks like they just copy a very big fil via loopback, and reco=
rd the
>> > time it took... quite simple.
>> >
>> > Their tests seems to be focused on CPU util/speed, graphics/games.
>> >
>> >
>> > The thing that caught my attention, was that they seemed intereste=
d in
>> > doing performance regression testing on all kernel versions...
>> >
>> > So, I though, it would be great if someone else would do automated
>> > performance regression testing for us :-), =A0Too bad they only ha=
ve a
>> > very simple network test.
>> >
>> >
>>
>
>>
>
> CC netdev, if you dont mind.
>
>
> Their network test is basically :
>
> netcat -l 9999 >/dev/null &
> time dd if=3D/dev/zero bs=3D1M count=3D10000 | netcat =A0127.0.0.1 99=
99
>
> They say it takes 38 seconds on their "super fast" processor
>
> On my dev machine, not super fast (E5540 @2.53GHz), I get 8 or 9
> seconds, even if only one CPU is online, all others offline.
>
> Go figure... maybe an artifact of the virtualization they use.
>
> I suspect some problem with the ticket spinlocks and a call to
> hypervisor to say 'I am spinning on a spinlock, see if you need to do
> something useful', or maybe ACPI problem (going to/from idle)
>
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
