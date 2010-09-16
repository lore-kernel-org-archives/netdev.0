From: Anand Raj Manickam <anandrm@gmail.com>
Subject: Re: Kernel Panic on OOM with 10 HTB rules
Date: Thu, 16 Sep 2010 17:50:39 +0530
Message-ID: <AANLkTi=H5WnSWBNW3s8M9cWfAt32JFyvNwNTSoYiiF1W@mail.gmail.com>
References: <AANLkTinQbuN4Y6yUgHhjhOkLGe3GPk9aN5z1gasvQ-zW@mail.gmail.com>
	<1283949778.2748.5.camel@edumazet-laptop>
	<4C91E4E1.4030001@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4C91E4E1.4030001@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Things seem to be fine now after i reduced imq devs txqueuelen to 32
and MTU to 1600 and no of imqs to 2.
Thank you all for the Suggestions .
Anand

On Thu, Sep 16, 2010 at 3:05 PM, Patrick McHardy <kaber@trash.net> wrot=
e:
> On 08.09.2010 14:42, Eric Dumazet wrote:
>> Le mercredi 08 septembre 2010 =E0 16:22 +0530, Anand Raj Manickam a
>> =E9crit :
>>> I m struck with
>>> Kernel Panic - Out of Memory Issue =A0when =A0traffic =A0is more th=
an 100k
>>> pps =A0and have =A0around 10 tc rules.
>>>
>>> There is NO kernel panic with 1 tc rule .
>>>
>>> I using a 2.6.34.6 ( latest stable kernel) with SMP enabled
>>>
>>> The rules are simple -
>>> 10 iptable rules :
>>> iptables -t mangle -I FORWARD -s x.x.x.x =A0-j CLASSIFY --set-class=
 0xz:0xy
>>>
>>> 10 tc rules :
>>> tc =A0class add dev imq0 parent 1:z classid 1:y htb rate 2kbit ceil=
 32768kbps
>>>
>>> I m using =A0Intel Xeon Quad core x5570, 12GB RAM , with 8 e1000e ,=
 irq
>>> affined ( 1 pair per core)
>>>
>>> There is NO issue / CRASH with multiple iptable rules marking to th=
e
>>> same tc rule/HTB class , i can sucessfully pass more than 200k pps =
/
>>> 800Mbps traffic .
>>>
>>> But when each iptable rule is marking to seprate tc rule/HTB class =
and
>>> when the traffic exceeds 100K pps / 20000 connections per second , =
we
>>> hit this Out of Memory - Kernel panic condition .
>>> Any help is appreciated . Do let me know if any more further
>>> information is need.
>>
>> Hi Anand
>>
>> Could you give :
>>
>> 1) A complete stack trace / panic report
>> 2) cat /proc/interrupts
>> 3) ifconfig -a
>> 4) cat /proc/sys/vm/min_free_kbytes
>> 5) cat /proc/meminfo
>>
>> for each eth*
>> =A0ethtool -g eth*
>
> Please try to reproduce without the imq patch.
>
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
