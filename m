From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Unexcepted latency (order of 100-200 ms) with TCP (packet receive)
Date: Thu, 26 Apr 2007 09:38:38 -0700
Message-ID: <4630D58E.5020709@hp.com>
References: <Pine.LNX.4.64.0704241518370.28337@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:53467 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754811AbXDZQil (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 12:38:41 -0400
In-Reply-To: <Pine.LNX.4.64.0704241518370.28337@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ilpo J=E4rvinen wrote:
> Hi,
>=20
> ...
> Some time ago I noticed that with 2.6.18 I occassionally get latency
> spikes as long as 100-200ms in the TCP transfers between components
> (I describe later how TCP was tuned during these tests to avoid
> problems that occur with small segments). I started to investigate
> the spikes, and here are the findings so far:
> ...
>  - I placed a hub to get exact timings on the wire without potential=20
>    interference from tcpdump on the emulator host (test done with 2.6=
=2E18)=20
>    but to my great surprise, the problem vanished completely

Sounds like tcpdump getting in the way?  How many CPUs do you have in=20
the system, and have you tried some explicit binding of processes to=20
different CPUs? (taskset etc...)

When running tcpdump are you simply sending raw traces to a file, or ar=
e=20
you having the ASCII redirected to a file?  What about name resolution=20
(ie areyou using -n)?

>  - Due to the hub test result, I tested 10/100/duplex settings and fo=
und=20
>    out that if the emulator host has 10fd, the problem does not occur=
 with
>    2.6 either?!? This could be due to luck but I cannot say for sure,=
 yet
>    the couple of tests I've run with 10fd, did not show this...
>  - Tried to change cable & switch that connect hosts together, no eff=
ect
>=20
>=20
> To prove this with 100Mbps, I setup routing so that with a host with =
10/FD=20
> configuration (known, based on earlier, to be unlikely to cause error=
s) I=20
> collected all traffic between the emulator host and one of the packet=
=20
> capture hosts. Here is one example point where a long delay occurs=20
> (EMU is the emulator host, in the real log each packet is shown twice=
, I=20
> only leave the later one here):
>=20
> 1177577267.364596 IP CAP.35305 > EMU.52246: . 17231434:17232894(1460)=
 ack 383357 win 16293
> 1177577267.364688 IP CAP.35305 > EMU.52246: P 17232894:17232946(52) a=
ck 383357 win 16293
> 1177577267.366093 IP EMU.52246 > CAP.35305: . ack 17232894 win 32718
> 1177577267.493815 IP EMU.52246 > CAP.35305: P 383357:383379(22) ack 1=
7232894 win 32718
> 1177577267.534252 IP CAP.35305 > EMU.52246: . ack 383379 win 16293

What is the length of the standalone ACK timer these days?

> 1177577267.534517 IP EMU.59050 > CAP.58452: P 624496:624528(32) ack 3=
28 win 365
> 1177577267.534730 IP CAP.58452 > EMU.59050: . ack 624528 win 16293
> 1177577267.536267 IP CAP.35305 > EMU.52246: . 17232946:17234406(1460)=
 ack 383379 win 16293
> 1177577267.536360 IP CAP.35305 > EMU.52246: P 17234406:17234458(52) a=
ck 383379 win 16293
> 1177577267.537764 IP EMU.52246 > CAP.35305: . ack 17234406 win 32718
> ...
> All things use TCP_NODELAY. The network is isolated so that=20
> no other traffic can cause unexcepted effects. The emulator does coll=
ect=20
> log only to a mem buffer that is flushed through TCP only between tes=
ts=20
> (and thus does not cause timing problems).

Might tcp_abc have crept back-in?

rick jones
