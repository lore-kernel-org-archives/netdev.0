From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Sun, 02 May 2010 16:27:28 +0200
Message-ID: <1272810448.2173.31.camel@edumazet-laptop>
References: <20100429182347.GA8512@gargoyle.fritz.box>
	 <1272568347.2209.11.camel@edumazet-laptop>
	 <20100429214144.GA10663@gargoyle.fritz.box>
	 <20100430.163857.180417789.davem@davemloft.net>
	 <20100501110000.GB9434@gargoyle.fritz.box>
	 <1272783366.2173.13.camel@edumazet-laptop>
	 <20100502092020.GA9655@gargoyle.fritz.box>
	 <1272797690.2173.26.camel@edumazet-laptop>
	 <20100502071324.1a95fdad@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	xiaosuo@gmail.com, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, lenb@kernel.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:62697 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756336Ab0EBO1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 10:27:34 -0400
Received: by bwz19 with SMTP id 19so879260bwz.21
        for <netdev@vger.kernel.org>; Sun, 02 May 2010 07:27:32 -0700 (PDT)
In-Reply-To: <20100502071324.1a95fdad@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 02 mai 2010 =C3=A0 07:13 -0700, Arjan van de Ven a =C3=A9cr=
it :
> >=20
> > Cn                Avg residency       P-states (frequencies)
> > C0 (cpu running)        (68.9%)         2.93 Ghz    46.5%
> > polling           0.0ms ( 0.0%)         2.80 Ghz     5.1%
> > C1 mwait          0.0ms ( 0.0%)         2.53 Ghz     3.0%
> > C2 mwait          0.0ms (31.1%)         2.13 Ghz     2.8%
> >                                         1.60 Ghz    38.2%
>=20
> I bet your system advertizes C2 with the same latency as C1,
> but with lower power... which means Linux will pretty much never
> pick C1.... no matter how much you take Andi's patch.
>=20
> this is a bios thing... and until we put in the patch to override the
> bios values (I can dust it off but it might need a bit of tweaking
> since it was against .31) Andi's patch alone won't cut it... you also
> need a non-lying bios ;)
>=20
>=20
>=20
# pwd
/sys/devices/system/cpu/cpu15/cpuidle
# grep . */*
state0/desc:CPUIDLE CORE POLL IDLE
state0/latency:0
state0/name:C0
state0/power:4294967295
state0/time:0
state0/usage:0
state1/desc:ACPI FFH INTEL MWAIT 0x0
state1/latency:1
state1/name:C1
state1/power:1000
state1/time:433855186
state1/usage:126869
state2/desc:ACPI FFH INTEL MWAIT 0x10
state2/latency:64
state2/name:C2
state2/power:500
state2/time:198095020416
state2/usage:76287744

C2 latency seems to be 64  (us ?), while C1 seems to be 1

BIOS Information
	Vendor: HP
	Version: I24
	Release Date: 10/01/2009

# powertop
PowerTOP 1.11   (C) 2007, 2008 Intel Corporation=20

Collecting data for 5 seconds=20


Your CPU supports the following C-states : C1 C2 C3=20
Your BIOS reports the following C-states : C1 C2=20

C3 seems to be disabled in BIOS


