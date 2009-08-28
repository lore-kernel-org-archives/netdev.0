From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2]: pkt_sched: Convert CBQ to tasklet_hrtimer.
Date: Fri, 28 Aug 2009 17:54:53 +0200
Message-ID: <4A97FDCD.10208@gmail.com>
References: <20090821.170333.153413841.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, tglx@linutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37499 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020AbZH1PzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 11:55:01 -0400
In-Reply-To: <20090821.170333.153413841.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> This code expects to run in softirq context, and bare hrtimers
> run in hw IRQ context.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>

=2E..

>  	sch->flags &=3D ~TCQ_F_THROTTLED;
> @@ -1214,7 +1216,7 @@ cbq_reset(struct Qdisc* sch)
>  	q->tx_class =3D NULL;
>  	q->tx_borrowed =3D NULL;
>  	qdisc_watchdog_cancel(&q->watchdog);
> -	hrtimer_cancel(&q->delay_timer);
> +	tasklet_hrtimer_cancel(&q->delay_timer);
>  	q->toplevel =3D TC_CBQ_MAXLEVEL;
>  	q->now =3D psched_get_time();
>  	q->now_rt =3D q->now;

David

I now have these dmesg warnings when playing with cbq

# tc qdisc del dev eth3 root
# tc qdisc add dev eth3 root handle 1: est 1sec 8sec cbq avpkt 1000 rat=
e 1000Mbit bandwidth 1000Mbit
# tc qdisc del dev eth3 root

[12786.458485] Attempt to kill tasklet from interrupt
[12786.458522] Attempt to kill tasklet from interrupt
[12786.465261] Attempt to kill tasklet from interrupt
[12786.465286] Attempt to kill tasklet from interrupt

probably becauce cbq_reset() being called from interrupt context ?

Thanks
