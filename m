From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RPS will assign different smp_processor_id for the same packet?
Date: Sun, 24 Apr 2011 10:00:33 +0200
Message-ID: <1303632033.2747.51.camel@edumazet-laptop>
References: <BANLkTimvuGKYuiV_ngTo4wtqhNix4iMfmA@mail.gmail.com>
	 <1303402094.3685.54.camel@edumazet-laptop>
	 <1303403112.3685.61.camel@edumazet-laptop>
	 <BANLkTi=gTNwKX1Tb3mqgWJekRf7n_MHpJQ@mail.gmail.com>
	 <BANLkTikY6CAZNkcnU-i7UvPpmSfQuXKtNQ@mail.gmail.com>
	 <BANLkTimqkq+2X3=RZ1Qb0e5NpO-yRxuCoQ@mail.gmail.com>
	 <BANLkTikyntWG6YPUdVipHvwJ8yGuU_Vi4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: zhou rui <zhourui.cn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33524 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755186Ab1DXIAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2011 04:00:54 -0400
Received: by wya21 with SMTP id 21so1067501wya.19
        for <netdev@vger.kernel.org>; Sun, 24 Apr 2011 01:00:53 -0700 (PDT)
In-Reply-To: <BANLkTikyntWG6YPUdVipHvwJ8yGuU_Vi4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 24 avril 2011 =C3=A0 10:00 +0800, zhou rui a =C3=A9crit :
> On Sun, Apr 24, 2011 at 3:56 AM, Tom Herbert <therbert@google.com> wr=
ote:
> > On Sat, Apr 23, 2011 at 8:31 AM, zhou rui <zhourui.cn@gmail.com> wr=
ote:
> >> one more question is:
> >>
> >> in the function "int netif_receive_skb(struct sk_buff *skb)"
> >>
> >> cpu =3D get_rps_cpu(skb->dev, skb, &rflow);
> >> if (cpu >=3D 0) {
> >>  ret =3D enqueue_to_backlog(skb, cpu, &rflow->last_qtail);
> >> ....
> >>
> >> probably the cpu is different from the current processor id?(smp_p=
rocessor_id)
> >> let's say: get_rps_cpu->cpu 0, smp_processor_id->cpu1
> >> when this happen, does it mean that cpu1 is handling the softirq b=
ut
> >> have to divert the packet to cpu0?(via a new softirq?)
> >>
> >> so for one packet it involve 2 softirqs?
> >>
> >> possible to get_rps_cpu in interrupt,then let the target cpu do on=
ly
> >> one softirq to hanle the packet?
> >>
> > Yes, this is what a non-NAPI driver would do.
> >
> > Tom
> >
> non-NAPI will get_rps_cpu in irq, but why NAPI will get_rps_cpu in
> softirq?(if I understand correctly netif_receive_skb executed in
> softirq?)

Thats hard to understand what your problem or question is.

All heavy Receive networking stuff is handled in softirq.

NAPI allows to reduce number of hardware IRQS in stress/load situations=
,
fetching several frames at once.



