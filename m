From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Multicast packet loss
Date: Tue, 3 Feb 2009 20:15:41 -0500
Message-ID: <20090204011541.GB3650@localhost.localdomain>
References: <49833DBC.7040607@athenacr.com> <20090130200330.GA12659@hmsreliant.think-freely.org> <49837F56.2020502@athenacr.com> <49838213.90700@cosmosbay.com> <20090131160333.GC23100@localhost.localdomain> <498723D9.5020509@athenacr.com> <20090203115502.GB28117@hmsreliant.think-freely.org> <498860AD.5010702@athenacr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Kenny Chang <kchang@athenacr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47696 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046AbZBDBPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 20:15:44 -0500
Content-Disposition: inline
In-Reply-To: <498860AD.5010702@athenacr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 03, 2009 at 10:20:13AM -0500, Kenny Chang wrote:
> Neil Horman wrote:
>> On Mon, Feb 02, 2009 at 11:48:25AM -0500, Kenny Chang wrote:
>>  =20
>>> Neil Horman wrote:
>>>    =20
>>>> On Fri, Jan 30, 2009 at 11:41:23PM +0100, Eric Dumazet wrote:
>>>>        =20
>>>>> Kenny Chang a =E9crit :
>>>>>            =20
>>>>>> Ah, sorry, here's the test program attached.
>>>>>>
>>>>>> We've tried 2.6.28.1, but no, we haven't tried the 2.6.28.2 or t=
he
>>>>>> 2.6.29.-rcX.
>>>>>>
>>>>>> Right now, we are trying to step through the kernel versions unt=
il we
>>>>>> see where the performance drops significantly.  We'll try 2.6.29=
-rc soon
>>>>>> and post the result.
>>>>>>                =20
>>>>> 2.6.29-rc contains UDP receive improvements (lockless)
>>>>>
>>>>> Problem is multicast handling was not yet updated, but could be :=
)
>>>>>
>>>>>
>>>>> I was asking you "cat /proc/interrupts" because I believe you mig=
ht
>>>>> have a problem NIC interrupts being handled by one CPU only (when=
 having problems)
>>>>>
>>>>>            =20
>>>> That would be expected (if irqbalance is running), and desireable,=
 since
>>>> spreading high volume interrupts like NICS accross multiple cores =
(or more
>>>> specifically multiple L2 caches), is going increase your cache lin=
e miss rate
>>>> significantly and decrease rx throughput.
>>>>
>>>> Although you do have a point here, if the system isn't running irq=
balance, and
>>>> the NICS irq affinity is spread accross multiple L2 caches, that w=
ould be a
>>>> point of improvement performance-wise. =20
>>>>
>>>> Kenny, if you could provide the /proc/interrupts info along with /=
proc/cpuinfo
>>>> and your stats that I asked about earlier, that would be a big hel=
p.
>>>>
>>>> Regards
>>>> Neil
>>>>
>>>>        =20
>>> This is for a working setup.
>>>
>>>    =20
>>
>> Are these quad core systems?  Or dual core w/ hyperthreading?  I ask=
 because in
>> your working setup you have 1/2 the number of cpus' and was not sure=
 if you
>> removed an entire package of if you just disabled hyperthreading.
>>
>>
>> Neil
>>
>>  =20
> Yeah, these are quad core systems.  The 8 cpu system is a dual-proces=
sor =20
> quad-core.  The other is my desktop, single cpu quad core.
>
Ok, so their separate systms then.  Did you actually experience drops o=
n the
8-core system since the last reboot?  I ask because even when its distr=
ibuted
across all 8 cores, you only have about 500 total interrupts from the N=
IC, and
if you did get drops, something more than just affinity is wrong.

Regardless, spreading interrupts across cores is definately a problem. =
 As eric
says, quad core chips are actually 2x2 cores, so you'll want to either =
just run
irqbalance to assign an apropriate affinity to the NIC, or manually loo=
k at each
cores physical id and sibling id, to assign affininty to a core or core=
s that
share an L2 cache.  If you need to, as you've found, you may need to di=
sable msi
interrupt mode on your bnx2 driver.  That kinda stinks, but bnx2 IIRC i=
sn't
multiqueue, so its not like msi provides you any real performance gain.

Neil

> Kenny
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
