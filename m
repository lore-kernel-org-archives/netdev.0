From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Bridge] [PATCH]  bridge: per-cpu packet statistics
Date: Tue, 2 Mar 2010 09:23:01 -0800
Message-ID: <20100302092301.7ca9b368@nehalam>
References: <20100301161658.5a61143b@nehalam>
	<1267520579.2964.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35955 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752344Ab0CBRX2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 12:23:28 -0500
In-Reply-To: <1267520579.2964.27.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 02 Mar 2010 10:02:59 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
>=20
> Le lundi 01 mars 2010 =C3=A0 16:16 -0800, Stephen Hemminger a =C3=A9c=
rit :
>=20
> > +	for_each_online_cpu(cpu) {
> > +		const struct br_cpu_netstats *bstats
> > +			=3D per_cpu_ptr(br->stats, cpu);
> > +
> > +		stats->rx_bytes   +=3D bstats->rx_bytes;
> > +		stats->rx_packets +=3D bstats->rx_packets;
> > +	}
>=20
> And last point, we should use for_each_possible_cpu() here
>=20
> Here is your patch with all my comments integrated :
>=20
> 1) Use txq->{tx_bytes|tx_packets} counter
>=20
> 2) alloc_percpu(struct ...) instead of alloc_percpu(sizeof(struct ...=
))
>=20
> 3) free_netdev() in destructor
>=20
> 4) for_each_possible_cpu() instead of for_each_online_cpu()
>=20
> 5) br_get_stats() use local variables for the sake of concurrent user=
s

No need, bridge has no queue!
