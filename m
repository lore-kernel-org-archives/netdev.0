From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/3] ifb: move tq from ifb_private
Date: Sun, 05 Dec 2010 16:13:36 +0100
Message-ID: <1291562016.2806.257.camel@edumazet-laptop>
References: <1291442121-3302-1-git-send-email-xiaosuo@gmail.com>
	 <1291442121-3302-3-git-send-email-xiaosuo@gmail.com>
	 <4CFA3F01.20109@gmail.com> <1291472889.2159.18.camel@mojatatu>
	 <1291474127.2159.35.camel@mojatatu> <20101204154007.GA1981@del.dom.local>
	 <1291478881.2159.70.camel@mojatatu> <20101204165609.GB1981@del.dom.local>
	 <AANLkTimnejoONxGqusiYVWOKbcy2yqbpFH-XyzgG0=87@mail.gmail.com>
	 <AANLkTimMvb187gOFzZZgWuzWJkk_Z3AOZaoc6M76H-e=@mail.gmail.com>
	 <1291559402.2159.687.camel@mojatatu>
	 <AANLkTimXDTTNcrFPngzEuoDGVgojtBxUZQPOMiSA7yNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, Jarek Poplawski <jarkao2@gmail.com>,
	netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47188 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755155Ab0LEPNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Dec 2010 10:13:44 -0500
Received: by wwa36 with SMTP id 36so11906658wwa.1
        for <netdev@vger.kernel.org>; Sun, 05 Dec 2010 07:13:43 -0800 (PST)
In-Reply-To: <AANLkTimXDTTNcrFPngzEuoDGVgojtBxUZQPOMiSA7yNw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 05 d=C3=A9cembre 2010 =C3=A0 22:40 +0800, Changli Gao a =C3=
=A9crit :
> On Sun, Dec 5, 2010 at 10:30 PM, jamal <hadi@cyberus.ca> wrote:
> > On Sun, 2010-12-05 at 09:13 +0800, Changli Gao wrote:
> >
> >> BTW: My ultimate goal is making ifb a multi-queue NIC, and the num=
ber
> >> of queues is equal to the number of the possible CPUs.
> >
> >
> > My view is this is going to be tricky because:
> > - we use tasklets. When we  reschedule we can end up on a differren=
t
> > cpu.
>=20
> The tasklets always been scheduled to the current CPU unless it has
> been schedule already on the other CPU.
>=20
> > -I dont see any point in having a separate softIRQ
> > - and if you do use other mechanisms it would require a lot more
> > testing since there are quiet a few use cases of ifb
> >
>=20
> I keep using tasklet. The attachment is the alpha version.
>=20

        for_each_possible_cpu(cpu) {
                q =3D per_cpu_ptr(p->q, cpu);
=2E..

        dev_ifb =3D alloc_netdev_mq(sizeof(struct ifb_private), "ifb%d"=
,
                                  ifb_setup, num_possible_cpus());

This is a very usual error.

You can have machines with 2 possibles cpus, numbered 0 and 8

Therere, you must use nr_cpu_ids here instead of num_possible_cpus()



