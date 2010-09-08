From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel Panic on OOM with 10 HTB rules
Date: Wed, 08 Sep 2010 14:42:58 +0200
Message-ID: <1283949778.2748.5.camel@edumazet-laptop>
References: <AANLkTinQbuN4Y6yUgHhjhOkLGe3GPk9aN5z1gasvQ-zW@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	shemminger@vyatta.com
To: Anand Raj Manickam <anandrm@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTinQbuN4Y6yUgHhjhOkLGe3GPk9aN5z1gasvQ-zW@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 08 septembre 2010 =C3=A0 16:22 +0530, Anand Raj Manickam a
=C3=A9crit :
> Hi,
>=20
> I m struck with
> Kernel Panic - Out of Memory Issue  when  traffic  is more than 100k
> pps  and have  around 10 tc rules.
>=20
> There is NO kernel panic with 1 tc rule .
>=20
> I using a 2.6.34.6 ( latest stable kernel) with SMP enabled
>=20
> The rules are simple -
> 10 iptable rules :
> iptables -t mangle -I FORWARD -s x.x.x.x  -j CLASSIFY --set-class 0xz=
:0xy
>=20
> 10 tc rules :
> tc  class add dev imq0 parent 1:z classid 1:y htb rate 2kbit ceil 327=
68kbps
>=20
> I m using  Intel Xeon Quad core x5570, 12GB RAM , with 8 e1000e , irq
> affined ( 1 pair per core)
>=20
> There is NO issue / CRASH with multiple iptable rules marking to the
> same tc rule/HTB class , i can sucessfully pass more than 200k pps /
> 800Mbps traffic .
>=20
> But when each iptable rule is marking to seprate tc rule/HTB class an=
d
> when the traffic exceeds 100K pps / 20000 connections per second , we
> hit this Out of Memory - Kernel panic condition .
> Any help is appreciated . Do let me know if any more further
> information is need.

Hi Anand

Could you give :

1) A complete stack trace / panic report
2) cat /proc/interrupts
3) ifconfig -a
4) cat /proc/sys/vm/min_free_kbytes
5) cat /proc/meminfo

for each eth*
 ethtool -g eth*



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
