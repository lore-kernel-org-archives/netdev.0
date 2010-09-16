From: Patrick McHardy <kaber@trash.net>
Subject: Re: Kernel Panic on OOM with 10 HTB rules
Date: Thu, 16 Sep 2010 11:35:29 +0200
Message-ID: <4C91E4E1.4030001@trash.net>
References: <AANLkTinQbuN4Y6yUgHhjhOkLGe3GPk9aN5z1gasvQ-zW@mail.gmail.com> <1283949778.2748.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, shemminger@vyatta.com
To: Anand Raj Manickam <anandrm@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1283949778.2748.5.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08.09.2010 14:42, Eric Dumazet wrote:
> Le mercredi 08 septembre 2010 =E0 16:22 +0530, Anand Raj Manickam a
> =E9crit :
>> I m struck with
>> Kernel Panic - Out of Memory Issue  when  traffic  is more than 100k
>> pps  and have  around 10 tc rules.
>>
>> There is NO kernel panic with 1 tc rule .
>>
>> I using a 2.6.34.6 ( latest stable kernel) with SMP enabled
>>
>> The rules are simple -
>> 10 iptable rules :
>> iptables -t mangle -I FORWARD -s x.x.x.x  -j CLASSIFY --set-class 0x=
z:0xy
>>
>> 10 tc rules :
>> tc  class add dev imq0 parent 1:z classid 1:y htb rate 2kbit ceil 32=
768kbps
>>
>> I m using  Intel Xeon Quad core x5570, 12GB RAM , with 8 e1000e , ir=
q
>> affined ( 1 pair per core)
>>
>> There is NO issue / CRASH with multiple iptable rules marking to the
>> same tc rule/HTB class , i can sucessfully pass more than 200k pps /
>> 800Mbps traffic .
>>
>> But when each iptable rule is marking to seprate tc rule/HTB class a=
nd
>> when the traffic exceeds 100K pps / 20000 connections per second , w=
e
>> hit this Out of Memory - Kernel panic condition .
>> Any help is appreciated . Do let me know if any more further
>> information is need.
>=20
> Hi Anand
>=20
> Could you give :
>=20
> 1) A complete stack trace / panic report
> 2) cat /proc/interrupts
> 3) ifconfig -a
> 4) cat /proc/sys/vm/min_free_kbytes
> 5) cat /proc/meminfo
>=20
> for each eth*
>  ethtool -g eth*

Please try to reproduce without the imq patch.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
