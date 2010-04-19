From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] rps: shortcut net_rps_action()
Date: Mon, 19 Apr 2010 15:27:07 +0200
Message-ID: <1271683627.3845.44.camel@edumazet-laptop>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271395106.16881.3645.camel@edumazet-laptop>
	 <1271424065.4606.31.camel@bigi>
	 <1271489739.16881.4586.camel@edumazet-laptop>
	 <1271525519.3929.3.camel@bigi>
	 <1271583573.16881.4798.camel@edumazet-laptop>
	 <1271590476.16881.4925.camel@edumazet-laptop>
	 <1271669822.16881.7520.camel@edumazet-laptop>
	 <k2u412e6f7f1004190248s8ac633beof2475645e799f2ea@mail.gmail.com>
	 <1271679244.3845.43.camel@edumazet-laptop>
	 <p2u412e6f7f1004190528l65cc6253w8b7f43f2657b551d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:48042 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754769Ab0DSN1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 09:27:13 -0400
Received: by bwz25 with SMTP id 25so5573663bwz.28
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 06:27:10 -0700 (PDT)
In-Reply-To: <p2u412e6f7f1004190528l65cc6253w8b7f43f2657b551d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 19 avril 2010 =C3=A0 20:28 +0800, Changli Gao a =C3=A9crit :
> On Mon, Apr 19, 2010 at 8:14 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> >
> > As several packets can be enqueued for a given cpu, we would need t=
o
> > keep bitmasks.
> > We would have to add one test in enqueue_to_backlog()
> >
> > if (cpu_test_and_set(cpu, mask)) {
> >        __raise_softirq_irqoff(NET_RX_SOFTIRQ);
> >        array[nb++] =3D cpu;
> > }
>=20
>         rps_lock(queue);
>         if (queue->input_pkt_queue.qlen <=3D netdev_max_backlog) {
>                 if (queue->input_pkt_queue.qlen) {
> ...
>                 if (napi_schedule_prep(&queue->backlog)) {
> #ifdef CONFIG_RPS
>                         if (cpu !=3D smp_processor_id()) {
>                                 struct rps_remote_softirq_cpus *rcpus=
 =3D
>                                     &__get_cpu_var(rps_remote_softirq=
_cpus);
>=20
>                                 cpu_set(cpu, rcpus->mask[rcpus->selec=
t]);
>                                 __raise_softirq_irqoff(NET_RX_SOFTIRQ=
);
>                                 goto enqueue;
>                         }
> #endif
>                         __napi_schedule(&queue->backlog);
>                 }
>=20
> Only the first packet of a softnet.input_pkt_queue may trigger IPI, s=
o
> we don't need to keep bitmasks.
>=20

This is not true Changli

Please read again all previous mails about RPS, or the code.



