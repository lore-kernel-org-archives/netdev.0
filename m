From: Albert Cahalan <acahalan@gmail.com>
Subject: Re: txqueuelen has wrong units; should be time
Date: Mon, 28 Feb 2011 11:37:45 -0500
Message-ID: <AANLkTimh1xWU9V9phOKZZMgOWKOmDDSBYfofnnOjjRh=@mail.gmail.com>
References: <AANLkTimd5GQwtUFP2fD_An=M8ajBD8DJpzxQJezv8fB8@mail.gmail.com>
	<alpine.DEB.1.10.1102270758580.11974@uplift.swm.pp.se>
	<1298793252.8726.45.camel@edumazet-laptop>
	<AANLkTinyE10wtM_xJsufT_3s3hvti7CN+9nyqScWa6SA@mail.gmail.com>
	<20110227125540.40754c5y78j9u2m8@hayate.sektori.org>
	<AANLkTimofhhH5omyk=HhkyaNG+MGqoac4rDf=dPuR7K-@mail.gmail.com>
	<cbb9e1113901f1a324359b6ed3f1a611@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Mikael Abrahamsson <swmike@swm.pp.se>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cbb9e1113901f1a324359b6ed3f1a611@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 28, 2011 at 10:38 AM, Hagen Paul Pfeifer <hagen@jauu.net> wrote:
> On Sun, 27 Feb 2011 18:33:39 -0500, Albert Cahalan wrote:
>
>> I suppose there is a need to allow at least 2 packets despite any
>> time limits, so that it remains possible to use a traditional modem
>> even if a huge packet takes several seconds to send.
>
> That is a good point! We talk about as we may know every use case of
> Linux. But this is not true at all. One of my customer for example operates
> the Linux network stack functionality on top of a proprietary MAC/Driver
> where the current packet queue characteristic is just fine. The
> time-drop-approach is unsuitable because the bandwidth can vary in a small
> amount of time over a great range (0 till max. bandwidth). A sufficient
> buffering shows up superior in this environment (only IPv{4,6}/UDP).

I don't think the current non-time queue is just fine for him.
I can see that time-based discard-on-enqueue would not be
fine either. He needs time-based discard-on-dequeue.
Good for him is probably:

On dequeue, discard all packets that are too old.
On enqueue, assume max bandwidth and discard all
packets that have no hope of surviving the dequeue check.
(the enqueue check is only to prevent wasting RAM)
Exception: always keep at least 2 packets.

Better is something that would allow random drop.
The trouble here is that bandwidth varies greatly.
Some sort of undelete functionality is needed...?

Assuming the difficulty with implementing random drop
is solvable, I think this would work for the rest of us too.

Keeping the timeout really low is important because it isn't
OK to eat up all the latency tolerance in one hop. You have
an end-to-end budget of 20 ms for usable GUI rubber banding.
The budget for gaming is about 80 and for VoIP is about 150.
