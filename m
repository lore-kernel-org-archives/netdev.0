From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Thu, 14 Apr 2011 12:08:59 -0700
Message-ID: <4DA7464B.5020309@intel.com>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>	 <1302267400.4409.22.camel@edumazet-laptop>	 <D12839161ADD3A4B8DA63D1A134D084026E48BA682@ESGSCCMS0001.eapac.ericsson.se>	 <1302275223.4409.36.camel@edumazet-laptop>	 <D12839161ADD3A4B8DA63D1A134D084026E48BA6AE@ESGSCCMS0001.eapac.ericsson.se>	 <1302330998.2656.113.camel@edumazet-laptop>	 <D12839161ADD3A4B8DA63D1A134D084026E48BA730@ESGSCCMS0001.eapac.ericsson.se>	 <4DA3151B.4030507@intel.com>	 <D12839161ADD3A4B8DA63D1A134D084026E4909714@ESGSCCMS0001.eapac.ericsson.se>	 <1302536577.4605.1.camel@edumazet-laptop>	 <D12839161ADD3A4B8DA63D1A134D084026E49535F2@ESGSCCMS0001.eapac.ericsson.se>	 <1302761251.3549.198.camel@edumazet-laptop>	 <1302762810.3549.233.camel@edumazet-laptop>	 <D12839161ADD3A4B8DA63D1A134D0
 84026E49536AF@ESGSCCMS0001.eapac.ericsson.se>	 <4DA723F1.7000901@intel.com>  <1302800202.2035.32.camel@laptop>	 <1302800221.3248.39.camel@edumazet-laptop> <1302803357.2744.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Wei Gu <wei.gu@ericsson.com>, netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Mike Galbraith <efault@gmx.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:3065 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932485Ab1DNTJA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Apr 2011 15:09:00 -0400
In-Reply-To: <1302803357.2744.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/14/2011 10:49 AM, Eric Dumazet wrote:
> Le jeudi 14 avril 2011 =C3=A0 18:57 +0200, Eric Dumazet a =C3=A9crit =
:
>> Le jeudi 14 avril 2011 =C3=A0 18:56 +0200, Peter Zijlstra a =C3=A9cr=
it :
>>> On Thu, 2011-04-14 at 09:42 -0700, Alexander Duyck wrote:
>>>
>>>> I'm doing some more digging into this now.  One thought that occur=
red to
>>>> me is that if the patch you mention is having some sort of effect =
this
>>>> could be a sign of perhaps a kernel timer or scheduling problem.
>>>
>>> Right, so the removal of the NO_HZ throttle will allow the CPU to g=
o
>>> into C states more often, this could result in longer wake-up times=
 for
>>> IRQs.
>>>
>>> We reverted because:
>>>    - it caused significant battery drain due to not going into C st=
ates
>>>      often enough, and
>>>    - its a much better idea to implement these things in the idle
>>>      governor since it already has the job of guestimating the idle
>>>      duration.
>>>
>>> I really can't remember back far enough to even come up with a theo=
ry of
>>> why kernels prior to merging the NO_HZ throttle would not exhibit t=
his
>>> problem.
>>>
>>>
>>>
>>
>> Normally, Wei Gu already asked to not use C states.
>>
>> http://h20000.www2.hp.com/bc/docs/support/SupportManual/c01804533/c0=
1804533.pdf
>>
>> How can we/he check this ?
>>
>>
>
> Anyway, this could explain a latency problem, not packet drops.
>
> With NAPI, we should get few hardware irqs under load.
>
> Once softirq started, scheduler is out of the equation.

The problem is on these newer systems it is becoming significantly=20
harder to get locked into the polling only state.  In many cases we wil=
l=20
just complete all of the RX work in a single poll and go back to=20
interrupts.  This is especially true when traffic is spread out across=20
multiple queues and CPUs.

I'm thinking that maybe powertop results for before that patch and afte=
r=20
that patch should be pretty telling.  It should tell us if C states are=
=20
active, and if so it will also tell us if we are being woken by=20
interrupts or if we are staying in the polling state.

Thanks,

Alex
