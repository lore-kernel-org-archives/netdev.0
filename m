From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] netfilter: get rid of atomic ops in fast path
Date: Sun, 20 Mar 2011 20:06:03 +0100
Message-ID: <1300647963.2831.291.camel@edumazet-laptop>
References: <1300468038.2888.160.camel@edumazet-laptop>
	 <4D86121C.7050503@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Jan Engelhardt <jengelh@medozas.de>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4D86121C.7050503@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 20 mars 2011 =C3=A0 15:41 +0100, Patrick McHardy a =C3=A9cr=
it :
> Am 18.03.2011 18:07, schrieb Eric Dumazet:
> > We currently use a percpu spinlock to 'protect' rule bytes/packets
> > counters, after various attempts to use RCU instead.
> >=20
> > Lately we added a seqlock so that get_counters() can run without
> > blocking BH or 'writers'. But we really use the seqcount in it.
> >=20
> > Spinlock itself is only locked by the current/owner cpu, so we can
> > remove it completely.
> >=20
> > This cleanups api, using correct 'writer' vs 'reader' semantic.
> >=20
> > At replace time, the get_counters() call makes sure all cpus are do=
ne
> > using the old table.
>=20
> I think this will have to wait until net-next opens up again since
> its not a bugfix.

Sure :)


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
