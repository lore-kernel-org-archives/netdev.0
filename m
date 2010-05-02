From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Sun, 02 May 2010 19:47:04 +0200
Message-ID: <1272822424.2173.138.camel@edumazet-laptop>
References: <20100429182347.GA8512@gargoyle.fritz.box>
	 <1272568347.2209.11.camel@edumazet-laptop>
	 <20100429214144.GA10663@gargoyle.fritz.box>
	 <20100430.163857.180417789.davem@davemloft.net>
	 <20100501110000.GB9434@gargoyle.fritz.box>
	 <1272783366.2173.13.camel@edumazet-laptop>
	 <20100502092020.GA9655@gargoyle.fritz.box>
	 <1272797690.2173.26.camel@edumazet-laptop>
	 <20100502154649.GA18063@gargoyle.fritz.box>
	 <1272818131.2173.127.camel@edumazet-laptop>
	 <20100502104304.6c6b2764@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	xiaosuo@gmail.com, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, lenb@kernel.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:43303 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758183Ab0EBRrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 13:47:11 -0400
Received: by bwz19 with SMTP id 19so934720bwz.21
        for <netdev@vger.kernel.org>; Sun, 02 May 2010 10:47:08 -0700 (PDT)
In-Reply-To: <20100502104304.6c6b2764@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 02 mai 2010 =C3=A0 10:43 -0700, Arjan van de Ven a =C3=A9cr=
it :
> On Sun, 02 May 2010 18:35:31 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote
> >=20
> >=20
> > You mean we can wakeup a thread with something else than an IPI ?
> >=20
>=20
> actually we can.
>=20
> mwait is not only "go idle", it is "go idle until someone writes to
> <THIS> cacheline". where <THIS> is set up with a "monitor" instructio=
n.
> We don't need to send an ipi per se.. all we need is to write to the
> right cacheline that we're monitoring.
>=20
>=20

Thats a bit x86 specific, isnt it ?

But we want to eventually send a 'signal' to a cpu, even if not blocked
in idle, so that it can do following action :

/* Called from hardirq (IPI) context */
static void rps_trigger_softirq(void *data)
{
        struct softnet_data *sd =3D data;

        __napi_schedule(&sd->backlog);
        __get_cpu_var(netdev_rx_stat).received_rps++;
}

And it also should be portable ;)

If something else than an IPI is available, please let us know !

Thanks


