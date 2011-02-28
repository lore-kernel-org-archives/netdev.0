From: John Heffner <johnwheffner@gmail.com>
Subject: Re: txqueuelen has wrong units; should be time
Date: Mon, 28 Feb 2011 16:45:56 -0500
Message-ID: <AANLkTinj5szpStmA+fZ1xggdyTS+sd8Y9jXaYquDNEjs@mail.gmail.com>
References: <AANLkTimd5GQwtUFP2fD_An=M8ajBD8DJpzxQJezv8fB8@mail.gmail.com>
	<alpine.DEB.1.10.1102270758580.11974@uplift.swm.pp.se>
	<1298793252.8726.45.camel@edumazet-laptop>
	<AANLkTinyE10wtM_xJsufT_3s3hvti7CN+9nyqScWa6SA@mail.gmail.com>
	<20110227125540.40754c5y78j9u2m8@hayate.sektori.org>
	<1298837273.8726.128.camel@edumazet-laptop>
	<20110228161115.GB2515@tuxdriver.com>
	<1298911694.2941.639.camel@edumazet-laptop>
	<20110228165501.GC2515@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Albert Cahalan <acahalan@gmail.com>,
	Mikael Abrahamsson <swmike@swm.pp.se>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110228165501.GC2515@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 28, 2011 at 11:55 AM, John W. Linville
<linville@tuxdriver.com> wrote:
> On Mon, Feb 28, 2011 at 05:48:14PM +0100, Eric Dumazet wrote:
>> Le lundi 28 f=E9vrier 2011 =E0 11:11 -0500, John W. Linville a =E9cr=
it :
>> > On Sun, Feb 27, 2011 at 09:07:53PM +0100, Eric Dumazet wrote:
>> >
>> > > Qdisc should return to caller a good indication packet is queued=
 or
>> > > dropped at enqueue() time... not later (aka : never)
>> > >
>> > > Accepting a packet at t0, and dropping it later at t0+limit with=
out
>> > > giving any indication to caller is a problem.
>> >
>> > Can you elaborate on what problem this causes? =A0Is it any worse =
than
>> > if the packet is dropped at some later hop?
>> >
>> > Is there any API that could report the drop to the sender (at
>> > least a local one) without having to wait for the ack timeout?
>> > Should there be?
>> >
>>
>> Not all protocols have ACKS ;)
>>
>> dev_queue_xmit() returns an error code, some callers use it.
>
> Well, OK -- I agree it is best if you can return the status at
> enqueue time. =A0The question becomes whether or not a dropped frame
> is worse than living with high latency. =A0The answer, of course, sti=
ll
> seems to be a bit subjective. =A0But, if the admin has determined tha=
t
> a link should be low latency...?

Notably, TCP is one caller that uses the error code.  The error code
is functionally equivalent to ECN, one of whose great advantages is
reducing delay jitter.  If TCP didn't get the error, that would
effectively double the latency for a full window of data, since the
dropped segment would not be retransmitted for an RTT.

  -John
