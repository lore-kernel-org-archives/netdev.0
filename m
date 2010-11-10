From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] macvlan: lockless tx path
Date: Wed, 10 Nov 2010 18:43:47 +0100
Message-ID: <1289411027.2860.248.camel@edumazet-laptop>
References: <1289403709.2860.216.camel@edumazet-laptop>
	 <4CDAD8C8.20807@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62842 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752655Ab0KJRny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 12:43:54 -0500
Received: by wwb39 with SMTP id 39so999594wwb.1
        for <netdev@vger.kernel.org>; Wed, 10 Nov 2010 09:43:53 -0800 (PST)
In-Reply-To: <4CDAD8C8.20807@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 10 novembre 2010 =C3=A0 09:39 -0800, Ben Greear a =C3=A9cri=
t :

> >   /**
> > - *	struct macvlan_rx_stats - MACVLAN percpu rx stats
> > + *	struct macvlan_pcpu_stats - MACVLAN percpu stats
> >    *	@rx_packets: number of received packets
> >    *	@rx_bytes: number of received bytes
> >    *	@rx_multicast: number of received multicast packets
> > + *	@tx_
>=20
> Minor nit..seems you missed a few there?
>=20

Arg... you're right !

> >    *	@syncp: synchronization point for 64bit counters
> >    *	@rx_errors: number of errors
> >    */
> > -struct macvlan_rx_stats {
> > +struct macvlan_pcpu_stats {
> >   	u64			rx_packets;
> >   	u64			rx_bytes;
> >   	u64			rx_multicast;
> > +	u64			tx_packets;
> > +	u64			tx_bytes;
> >   	struct u64_stats_sync	syncp;
> >   	unsigned long		rx_errors;
> > +	unsigned long		tx_dropped;
>=20
> Any reason to not also make those u64?
>=20

Well, they are supposed to be not incremented often, and they are packe=
t
counts only, so a wrap around in less than 5 seconds is very unlikely.



