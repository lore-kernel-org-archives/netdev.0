From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: big picture UDP/IP performance question re 2.6.18  -> 2.6.32
Date: Tue, 11 Oct 2011 10:24:31 -0600
Message-ID: <4E946DBF.5050105@genband.com>
References: <6.2.5.6.2.20111006231958.039bb570@binnacle.cx> <1317966007.3457.47.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: starlight@binnacle.cx, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Christoph Lameter <cl@gentwo.org>, Willy Tarreau <w@1wt.eu>,
	Ingo Molnar <mingo@elte.hu>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Benjamin LaHaise <bcrl@kvack.org>,
	Joe Perches <joe@perches.com>,
	Chetan Loke <Chetan.Loke@netscout.com>,
	Con Kolivas <conman@kolivas.org>,
	Serge Belyshev <belyshev@depni.sinp.msu.ru>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1317966007.3457.47.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/06/2011 11:40 PM, Eric Dumazet wrote:
> Le jeudi 06 octobre 2011 =E0 23:27 -0400, starlight@binnacle.cx a =E9=
crit :

>> If the older kernels are switching to NAPI
>> for much of surge and the switching out
>> once the pulse falls off, it might
>> conceivably result in much better latency
>> and overall performance.

> Thats exactly the opposite : Your old kernel is not fast enough to
> enter/exit NAPI on every incoming frame.
>
> Instead of one IRQ per incoming frame, you have less interrupts :
> A napi run processes more than 1 frame.
>
> Now increase your incoming rate, and you'll discover a new kernel wil=
l
> be able to process more frames without losses.

I wonder if it would make sense to adjust the interrupt mitigation=20
parameters in the NIC to allow it to accumulate a few packets before=20
interrupting the CPU.  We had good luck using this to reduce interrupt=20
rate on a quasi-pathological case where we were bouncing in and out of=20
NAPI because we were *just* fast enough to keep up with incoming packet=
s.

Chris



--=20
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
