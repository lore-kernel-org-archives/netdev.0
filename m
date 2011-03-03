From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sched: QFQ - quick fair queue scheduler (v2)
Date: Thu, 03 Mar 2011 17:03:55 +0100
Message-ID: <1299168235.2983.116.camel@edumazet-laptop>
References: <20110228171738.2cc8c9a0@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Fabio Checconi <fabio@gandalf.sssup.it>,
	Luigi Rizzo <rizzo@iet.unipi.it>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:52063 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751786Ab1CCQFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 11:05:05 -0500
Received: by bwz15 with SMTP id 15so1274099bwz.19
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 08:05:04 -0800 (PST)
In-Reply-To: <20110228171738.2cc8c9a0@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 f=C3=A9vrier 2011 =C3=A0 17:17 -0800, Stephen Hemminger a =C3=
=A9crit :


> +static int qfq_dump_class_stats(struct Qdisc *sch, unsigned long arg=
,
> +				struct gnet_dump *d)
> +{
> +	struct qfq_class *cl =3D (struct qfq_class *)arg;
> +	struct tc_qfq_stats xstats;
> +
> +	memset(&xstats, 0, sizeof(xstats));
> +
> +	xstats.weight =3D ONE_FP/cl->inv_w;
> +	xstats.lmax =3D cl->lmax;
> +

cl->qdisc->qstats.qlen =3D cl->qdisc->q.qlen;

> +	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
> +	    gnet_stats_copy_rate_est(d, NULL, &cl->rate_est) < 0 ||
> +	    gnet_stats_copy_queue(d, &cl->qdisc->qstats) < 0)
> +		return -1;
> +
> +	return gnet_stats_copy_app(d, &xstats, sizeof(xstats));
> +}
> +

using=20
	gnet_stats_copy_rate_est(d, &cl->bstats, &cl->rate_est) < 0=20

is better : We avoid dumping null rate estimation, if admin never asked
a rate estimation...



