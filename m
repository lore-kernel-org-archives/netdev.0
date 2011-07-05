From: Alexey Zaytsev <alexey.zaytsev@gmail.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison overwritten
Date: Tue, 5 Jul 2011 08:57:15 +0400
Message-ID: <CAB9v_DFM8PcujUB-YzcK49DS7T6Bz2FLDtkVdEYt8an1oPYVFw@mail.gmail.com>
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
	<CAB9v_DGSFAG9V0jqem+tDP3G-N8v6Z+_6oKdPwL-ZwhfhCOZnw@mail.gmail.com>
	<1309839928.2720.23.camel@edumazet-laptop>
	<CAB9v_DEOhZh37aqx1qrLnrz5+tqjcjgBx-DP6M_0NkygZ1LjcQ@mail.gmail.com>
	<1309840708.2720.31.camel@edumazet-laptop>
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
Received: from mail-vx0-f174.google.com ([209.85.220.174]:40630 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753271Ab1GEE5R convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 00:57:17 -0400
Received: by vxb39 with SMTP id 39so3939387vxb.19
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2011 21:57:16 -0700 (PDT)
In-Reply-To: <1309840708.2720.31.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 5, 2011 at 08:38, Eric Dumazet <eric.dumazet@gmail.com> wro=
te:
> Le mardi 05 juillet 2011 =C3=A0 08:29 +0400, Alexey Zaytsev a =C3=A9c=
rit :
>> On Tue, Jul 5, 2011 at 08:25, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
>> > Le mardi 05 juillet 2011 =C3=A0 08:17 +0400, Alexey Zaytsev a =C3=A9=
crit :
>> >> >
>> >> Check out starting at packet 302893. 383 _identical_ ACKs were se=
nt
>> >> out by the b44 machine within 30 milliseconds.
>> >
>> >
>> > As I said, b44 driver lost at least 200 consecutive frames (source=
 says
>> > recovery takes about 20 ms)
>> >
>> > TCP then do its normal job.
>> >
>>
>> From my understanding, after a frame is lost, TCP would be waiting f=
or
>> a retransmit. Or at least, it would not be sending 400 duplicate ACK=
s
>> for the single last frame received, right? Let me run tcpdump on the
>> b44 side now. I'm quite sure I won't see any ACK dups leaving the
>> stack.
>
> Wow, I believe you are on a wrong track. Honestly.
>
> Try to unpplug the wire for 100ms, and watch your "duplicate acks
> disease".
>
> Thats exactly what is happening with b44 driver doing a "fast recover=
y"
> right now.
>
> Thats a moot point. Running tcpdump on your b44 machine will kill you=
r
> performance even more, it wont solve the b44 bug.
>
> If you prefer to 'fix tcp', please open another thread.

Ran tcpdump. You are right, I was wrong. Sorry for the noise.
