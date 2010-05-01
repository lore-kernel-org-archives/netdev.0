From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: speedup udp receive path
Date: Sat, 1 May 2010 18:24:00 +0800
Message-ID: <o2u412e6f7f1005010324sfb63393fo86acdff4c97c5be3@mail.gmail.com>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	<1272548258.4258.185.camel@bigi> <1272548980.2222.87.camel@edumazet-laptop>
	<1272549408.4258.189.camel@bigi> <1272573383.3969.8.camel@bigi>
	<1272655814.3879.8.camel@bigi> <1272660000.2230.4.camel@edumazet-laptop>
	<1272672394.14499.1.camel@bigi> <1272693424.2230.75.camel@edumazet-laptop>
	<1272694442.2230.86.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, David Miller <davem@davemloft.net>,
	therbert@google.com, shemminger@vyatta.com, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>,
	Brian Bloniarz <bmb@athenacr.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:64238 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751957Ab0EAKYU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 06:24:20 -0400
Received: by pwj9 with SMTP id 9so585782pwj.19
        for <netdev@vger.kernel.org>; Sat, 01 May 2010 03:24:20 -0700 (PDT)
In-Reply-To: <1272694442.2230.86.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 1, 2010 at 2:14 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
>
> BTW, using ee mask, cpu4 is not used at _all_, even for the user
> threads. Scheduler does a bad job IMHO.
>
> Using fe mask, I get all packets (sent at 733311pps by my pktgen
> machine), and my CPU0 even has idle time !!!
>
> Limit seems to be around 800.000 pps
>
> ---------------------------------------------------------------------=
---------------------------------------------------
> =C2=A0 PerfTop: =C2=A0 =C2=A05616 irqs/sec =C2=A0kernel:93.9% [1000Hz=
 cycles], =C2=A0(all, 8 CPUs)
> ---------------------------------------------------------------------=
---------------------------------------------------
>

Oh, cpu0 usage is about 100-(100-93.9)*8 =3D 51.2%(Am I right?). If we
can do weighted packet distributing: cpu0's weight is 1, and other
cpus are 2. maybe we can utilize all the cpu power.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
