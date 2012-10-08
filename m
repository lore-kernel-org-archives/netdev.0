From: =?UTF-8?Q?Nie=C5=9Bcierowicz_Adam?= <adam.niescierowicz@justnet.pl>
Subject: Re: 3.4.1 and 3.5-rc1 Packet lost at 250Mb/s
Date: Mon, 08 Oct 2012 12:49:53 +0200
Message-ID: <80bb011e8f1289218087633fd7b115ea@justnet.pl>
References: <409ac8b30a6994028562e1a159ac60aa@justnet.pl>
 <1349677373.21172.2756.camel@edumazet-glaptop>
 <9819d6943a7cfddfc8fa49217aa4842e@justnet.pl>
 <1349689640.21172.3008.camel@edumazet-glaptop>
Reply-To: <adam.niescierowicz@justnet.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host-91.230.163.37.ltv.pl ([91.230.163.37]:38730 "EHLO
	mail.justnet.pl" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751755Ab2JHKuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 06:50:05 -0400
In-Reply-To: <1349689640.21172.3008.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 08.10.2012 11:47, Eric Dumazet napisa=C5=82(a):

> On Mon, 2012-10-08 at 11:29 +0200, Nie=C5=9Bcierowicz Adam wrote:
>
>>> You should use RPS on eth2/eth3 because they are non multi queue.
>>> Documentation/networking/scaling.txt should give you all the needed
>>> info
>> I set processors for rps such as affinity, unfortunately it did not
>> help --- cat /sys/class/net/eth{2,3,4,5}/queues/rx-0/rps_cpus 0040=20
>> 0080
>> 0100 0200 --- CPU affinity http://wklej.org/id/843161/ [1]
>
> I said eth2 and eth3
>

eth2,eth3 and eth4,eth5 is the same card so I changed them as well, or=20
made =E2=80=8B=E2=80=8Ba mistake?

> And you should use cpu11->cpu15 instead of cpu6->cpu9 since they are=20
> in
> use...
>

I read in the file Documentation/networking/scaling.txt
---
if the rps_cpus for each queue are the ones that
share the same memory domain as the interrupting CPU for that queue
---

so i used the same CPU, I misunderstood?


> Anyway you dont say where are drops, (ifconfig give us very few=20
> drops)

you can see no losses(drop), but a temporary decline in traffic on the=20
interface to 0kb/s

>
> Also your eth0 seems to have a strange balance :
>
> RX interrupts seems to be well balanced on 4 queues :
>
> 76: 503 0 169271690 0 0 0 PCI-MSI-edge eth0-rx-0
> 77: 405 0 0 164532538 0 0 PCI-MSI-edge eth0-rx-1
> 78: 408 0 0 0 152778723 0 PCI-MSI-edge eth0-rx-2
> 79: 349 0 0 0 0 155011301 PCI-MSI-edge eth0-rx-3
> 80: 144 0 443432394 0 0 0 PCI-MSI-edge eth0-tx-0
> 81: 18 0 0 2043311 0 0 PCI-MSI-edge eth0-tx-1
> 82: 30 0 0 0 1934537 0 PCI-MSI-edge eth0-tx-2
> 83: 137 0 0 0 0 1968272 PCI-MSI-edge eth0-tx-3
>
> But TX seems to mostly use queue 0
>
> Packets sent to eth0 are coming from where ?

Packets come mainly from two routers(Edge BGP and local NAT)
