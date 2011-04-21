From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RPS will assign different smp_processor_id for the same packet?
Date: Thu, 21 Apr 2011 18:25:12 +0200
Message-ID: <1303403112.3685.61.camel@edumazet-laptop>
References: <BANLkTimvuGKYuiV_ngTo4wtqhNix4iMfmA@mail.gmail.com>
	 <1303402094.3685.54.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: zhou rui <zhourui.cn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54773 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753621Ab1DUQZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 12:25:16 -0400
Received: by wya21 with SMTP id 21so1560937wya.19
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 09:25:15 -0700 (PDT)
In-Reply-To: <1303402094.3685.54.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 21 avril 2011 =C3=A0 18:08 +0200, Eric Dumazet a =C3=A9crit :
> Le jeudi 21 avril 2011 =C3=A0 23:50 +0800, zhou rui a =C3=A9crit :
> > kernel 2.6.36.4
> > CONFIG_RPS=3Dy but not set the cpu mask
> >=20
> > /sys/class/net/eth1/queues/rx-0 # cat rps_cpus
> > 00
> >=20
> > register a hook func:
> >   prot_hook.func =3D packet_rcv;
> >   prot_hook.type =3D htons(ETH_P_ALL);
> >   dev_add_pack(&prot_hook);
> >=20
> >=20
> > replay the same traffic in very slow speed, printk the
> > smp_processor_id in packet_rcv():
> > first time:
> > cpu=3D4
> > cpu=3D3
> > cpu=3D6
> > cpu=3D7
> >=20
> > second time:
> > cpu=3D7
> > cpu=3D1
> > cpu=3D5
> > cpu=3D2
> >=20
> > is it normal?
>=20
> Yes it is.
>=20
> What would you expect ?
>=20

If rps_cpus contains only '0' bits, it basically means RPS is not activ=
e
for this input queue.

CPU is therefore not changed : The cpu handling NAPI on your network
device directly calls upper linux stack.

Seeing your traces, it also means your device spreads its interrupts on
many different cpus, this might be not optimal.

Check /proc/irq/{irq_number}/smp_affinity, it probably contains "ff"



