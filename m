From: Anand Raj Manickam <anandrm@gmail.com>
Subject: Kernel Panic on OOM with 10 HTB rules
Date: Wed, 8 Sep 2010 16:22:28 +0530
Message-ID: <AANLkTinQbuN4Y6yUgHhjhOkLGe3GPk9aN5z1gasvQ-zW@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	shemminger@vyatta.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I m struck with
Kernel Panic - Out of Memory Issue  when  traffic  is more than 100k
pps  and have  around 10 tc rules.

There is NO kernel panic with 1 tc rule .

I using a 2.6.34.6 ( latest stable kernel) with SMP enabled

The rules are simple -
10 iptable rules :
iptables -t mangle -I FORWARD -s x.x.x.x  -j CLASSIFY --set-class 0xz:0xy

10 tc rules :
tc  class add dev imq0 parent 1:z classid 1:y htb rate 2kbit ceil 32768kbps

I m using  Intel Xeon Quad core x5570, 12GB RAM , with 8 e1000e , irq
affined ( 1 pair per core)

There is NO issue / CRASH with multiple iptable rules marking to the
same tc rule/HTB class , i can sucessfully pass more than 200k pps /
800Mbps traffic .

But when each iptable rule is marking to seprate tc rule/HTB class and
when the traffic exceeds 100K pps / 20000 connections per second , we
hit this Out of Memory - Kernel panic condition .
Any help is appreciated . Do let me know if any more further
information is need.

Thanks,
Anand
