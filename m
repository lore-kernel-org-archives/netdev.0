From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RPS will assign different smp_processor_id for the same packet?
Date: Sun, 24 Apr 2011 12:53:36 +0200
Message-ID: <1303642416.2747.74.camel@edumazet-laptop>
References: <BANLkTimvuGKYuiV_ngTo4wtqhNix4iMfmA@mail.gmail.com>
	 <1303402094.3685.54.camel@edumazet-laptop>
	 <1303403112.3685.61.camel@edumazet-laptop>
	 <BANLkTi=gTNwKX1Tb3mqgWJekRf7n_MHpJQ@mail.gmail.com>
	 <BANLkTikY6CAZNkcnU-i7UvPpmSfQuXKtNQ@mail.gmail.com>
	 <BANLkTimqkq+2X3=RZ1Qb0e5NpO-yRxuCoQ@mail.gmail.com>
	 <BANLkTikyntWG6YPUdVipHvwJ8yGuU_Vi4w@mail.gmail.com>
	 <1303632033.2747.51.camel@edumazet-laptop>
	 <BANLkTintzzpixPi+HDzGUV_agCGr6EX7AQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: zhou rui <zhourui.cn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38049 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756505Ab1DXKxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2011 06:53:40 -0400
Received: by wya21 with SMTP id 21so1105844wya.19
        for <netdev@vger.kernel.org>; Sun, 24 Apr 2011 03:53:39 -0700 (PDT)
In-Reply-To: <BANLkTintzzpixPi+HDzGUV_agCGr6EX7AQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 24 avril 2011 =C3=A0 17:36 +0800, zhou rui a =C3=A9crit :
> >
>=20
> my understanding:
>=20
> non-NAPI scenario:
>=20
> netif_rx( in irq, get_rps_cpu,enqueue_to_backlog to deliver packet to
> cpu queue) ------>net_rx_action(in softirq,deque and process packet)
>=20
>=20
> NAPI:
>=20
> what does RPS do?(in
> irq)------------------------>net_rx_action(softirq)----->netif_receiv=
e_skb(get_rps_cpu,enque
> packet)
>=20
> so my question is:
> for NAPI, get_rps_cpu will be done in softirq?
>=20


> if the above situation is true,will this happen?
> packet_for_cpu_1 --> cpu0(netif_receive_skb,in softirq) --->delivered
> to cpu1(softirq)

NAPI is done under softirq, yes.

netif_receive_skb()
	cpu =3D get_rps_cpu()
	if (othercpu(cpu))
		enqueue_to_backlog(cpu)
	else
		__netif_receive_skb(skb);


enqueue_to_backlog() triggers an IPI (hard IRQ) to other cpu1,
to queue an NAPI context. (and triggers softirq)



