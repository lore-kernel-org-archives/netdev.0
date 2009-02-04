From: Kenny Chang <kchang@athenacr.com>
Subject: Re: Multicast packet loss
Date: Wed, 04 Feb 2009 11:07:13 -0500
Message-ID: <4989BD31.306@athenacr.com>
References: <49833DBC.7040607@athenacr.com> <20090130200330.GA12659@hmsreliant.think-freely.org> <49837F56.2020502@athenacr.com> <49838213.90700@cosmosbay.com> <20090131160333.GC23100@localhost.localdomain> <498723D9.5020509@athenacr.com> <20090203115502.GB28117@hmsreliant.think-freely.org> <498860AD.5010702@athenacr.com> <20090204011541.GB3650@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.95.46.209] ([64.95.46.209]:1067 "EHLO
	sprinkles.inp.in.athenacr.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753926AbZBDQHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 11:07:20 -0500
In-Reply-To: <20090204011541.GB3650@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman wrote:
> On Tue, Feb 03, 2009 at 10:20:13AM -0500, Kenny Chang wrote:
>  =20
>> Neil Horman wrote:
>>    =20
>>> On Mon, Feb 02, 2009 at 11:48:25AM -0500, Kenny Chang wrote:
>>>  =20
>>>      =20
>>>> Neil Horman wrote:
>>>>    =20
>>>>        =20
>>>>> On Fri, Jan 30, 2009 at 11:41:23PM +0100, Eric Dumazet wrote:
>>>>>        =20
>>>>>          =20
>>>>>> Kenny Chang a =E9crit :
>>>>>>            =20
>>>>>>            =20
>>>>>>> Ah, sorry, here's the test program attached.
>>>>>>>
>>>>>>> We've tried 2.6.28.1, but no, we haven't tried the 2.6.28.2 or =
the
>>>>>>> 2.6.29.-rcX.
>>>>>>>
>>>>>>> Right now, we are trying to step through the kernel versions un=
til we
>>>>>>> see where the performance drops significantly.  We'll try 2.6.2=
9-rc soon
>>>>>>> and post the result.
>>>>>>>                =20
>>>>>>>              =20
>>>>>> 2.6.29-rc contains UDP receive improvements (lockless)
>>>>>>
>>>>>> Problem is multicast handling was not yet updated, but could be =
:)
>>>>>>
>>>>>>
>>>>>> I was asking you "cat /proc/interrupts" because I believe you mi=
ght
>>>>>> have a problem NIC interrupts being handled by one CPU only (whe=
n having problems)
>>>>>>
>>>>>>            =20
>>>>>>            =20
>>>>> That would be expected (if irqbalance is running), and desireable=
, since
>>>>> spreading high volume interrupts like NICS accross multiple cores=
 (or more
>>>>> specifically multiple L2 caches), is going increase your cache li=
ne miss rate
>>>>> significantly and decrease rx throughput.
>>>>>
>>>>> Although you do have a point here, if the system isn't running ir=
qbalance, and
>>>>> the NICS irq affinity is spread accross multiple L2 caches, that =
would be a
>>>>> point of improvement performance-wise. =20
>>>>>
>>>>> Kenny, if you could provide the /proc/interrupts info along with =
/proc/cpuinfo
>>>>> and your stats that I asked about earlier, that would be a big he=
lp.
>>>>>
>>>>> Regards
>>>>> Neil
>>>>>
>>>>>        =20
>>>>>          =20
>>>> This is for a working setup.
>>>>
>>>>    =20
>>>>        =20
>>> Are these quad core systems?  Or dual core w/ hyperthreading?  I as=
k because in
>>> your working setup you have 1/2 the number of cpus' and was not sur=
e if you
>>> removed an entire package of if you just disabled hyperthreading.
>>>
>>>
>>> Neil
>>>
>>>  =20
>>>      =20
>> Yeah, these are quad core systems.  The 8 cpu system is a dual-proce=
ssor =20
>> quad-core.  The other is my desktop, single cpu quad core.
>>
>>    =20
> Ok, so their separate systms then.  Did you actually experience drops=
 on the
> 8-core system since the last reboot?  I ask because even when its dis=
tributed
> across all 8 cores, you only have about 500 total interrupts from the=
 NIC, and
> if you did get drops, something more than just affinity is wrong.
>
> Regardless, spreading interrupts across cores is definately a problem=
=2E  As eric
> says, quad core chips are actually 2x2 cores, so you'll want to eithe=
r just run
> irqbalance to assign an apropriate affinity to the NIC, or manually l=
ook at each
> cores physical id and sibling id, to assign affininty to a core or co=
res that
> share an L2 cache.  If you need to, as you've found, you may need to =
disable msi
> interrupt mode on your bnx2 driver.  That kinda stinks, but bnx2 IIRC=
 isn't
> multiqueue, so its not like msi provides you any real performance gai=
n.
>
> Neil
>
>  =20
Hi Neil,

Yeah, we've been rebooting this system left and right switch kernels. =20
The results are fairly consistent.  We were able to set the irq=20
affinities, and as Wes had mentioned, what we see is that if we pin the=
=20
softirq to 1 core, and pin the app to its sibling, we see really good=20
performance, but as we load up other cores, the machine reaches a=20
breaking point where all hell breaks loose and we drop a bunch.  (we=20
hadn't turned off msi btw..)

While we were able to tune and adjust performance like that, in the end=
,=20
it doesn't really explain the difference between earlier and recent=20
kernels, also it doesn't quite explain the difference between machines.

You mentioned it would be good to see the interrupts for each kernel, i=
n=20
light of the above information, would it still be useful for me to=20
provide that?

Kenny

