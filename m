From: Alexey Zaytsev <alexey.zaytsev@gmail.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison overwritten
Date: Tue, 5 Jul 2011 08:17:37 +0400
Message-ID: <CAB9v_DGSFAG9V0jqem+tDP3G-N8v6Z+_6oKdPwL-ZwhfhCOZnw@mail.gmail.com>
References: <bug-38102-10286@https.bugzilla.kernel.org/>
	<20110629145135.5179fb0c.akpm@linux-foundation.org>
	<BANLkTi=PxH8V58k-VycsM=1ZiE9hPqCN4Q@mail.gmail.com>
	<CAB9v_DHXB6n07sEY_=HZ8S4zMO01Vs8B78dGyEWrm-hyRP82XA@mail.gmail.com>
	<1309707971.2523.20.camel@edumazet-laptop>
	<CAB9v_DG7e8vDE+4PDwuOR2DYG1FEvUM1fxa+e4a=swwTYGJ9nQ@mail.gmail.com>
	<20110704130531.37cf876e@Nokia-N900>
	<1309787822.2247.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20110704162726.4072e715@maggie>
	<20110704164351.338dc12e@maggie>
	<1309792323.2247.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CAB9v_DHHmeFtQ4jrtVRSGWBvB=W_=QBHCvMi-u25e0nPBQ1jAA@mail.gmail.com>
	<CAB9v_DFFX6cHAFBSOGDJRniehJ6pYD7Z5XG6ygTGHy8j=z+U0g@mail.gmail.com>
	<1309837443.2720.8.camel@edumazet-laptop>
	<CAB9v_DFYGyYiXGfMCXn_WDeGTKz8BZPYBCuaDj_a+5VAG3Jn=g@mail.gmail.com>
	<1309839068.2720.15.camel@edumazet-laptop>
	<1309839258.2720.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Michael_B=C3=BCsch?= <m@bues.ch>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Pietikainen <pp@ee.oulu.fi>,
	Florian Schirmer <jolt@tuxbox.org>,
	Felix Fietkau <nbd@openwrt.org>, Michael Buesch <mb@bu3sch.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:34590 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757Ab1GEERi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 00:17:38 -0400
Received: by vws1 with SMTP id 1so3944664vws.19
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2011 21:17:37 -0700 (PDT)
In-Reply-To: <1309839258.2720.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 5, 2011 at 08:14, Eric Dumazet <eric.dumazet@gmail.com> wro=
te:
> Le mardi 05 juillet 2011 =C3=A0 06:11 +0200, Eric Dumazet a =C3=A9cri=
t :
>> Le mardi 05 juillet 2011 =C3=A0 07:56 +0400, Alexey Zaytsev a =C3=A9=
crit :
>> > On Tue, Jul 5, 2011 at 07:44, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
>> > >
>> > > I dont care about duplicate acks at this point.
>> > >
>> > > Thats a separate issue (TCP layer)
>> > >
>> >
>> > Maybe some tx packets are just sent out more then once? Or a singl=
e
>> > packet is sent out instead of some other packets?
>> > The delays between two dups is short, and they come in bursts, up =
to a
>> > few hundreds of duplicate packets at a time.
>> >
>>
>> Thats a completely different problem. SSH is very expensive for your
>> receiver (your dump1 file has small packets (560 bytes)), and it can=
not
>> cope with the stress.
>>
>> You're filling the b44 rx ring, and b44 driver has no choice to zap =
200
>> packets at once. This sure is a problem for tcp, as it stalls the th=
ing.
>>
>> You could avoid this by doing this at b44 machine (the receiver)
>>
>> echo "4096 32768 87380" >/proc/sys/net/ipv4/tcp_rmem
>>
>> So that sender wont be able to push so many packets
>
> You can also try using more packets in rx ring : (default is 200
> packets, limit ~511)
>
> ethtool -G eth0 rx 400
>
>
Check out starting at packet 302893. 383 _identical_ ACKs were sent
out by the b44 machine within 30 milliseconds.

>
>
