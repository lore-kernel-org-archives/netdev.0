From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 1/4]: net: Allow RX queue selection to seed TX queue	hashing.
Date: Wed, 28 Jan 2009 10:29:14 +0100
Message-ID: <4980256A.7050908@cosmosbay.com>
References: <20090128085358.GA15593@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55708 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753018AbZA1J30 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 04:29:26 -0500
In-Reply-To: <20090128085358.GA15593@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu a =E9crit :
> David Miller <davem@davemloft.net> wrote:
>> +       if (skb_rx_queue_recorded(skb)) {
>> +               u32 val =3D skb_get_rx_queue(skb);
>> +
>> +               hash =3D jhash_1word(val, simple_tx_hashrnd);
>=20
> I'm not so sure about this added randomness.  On the one hand
> I can see the benefit in being defensive about hashing, but this
> does pose a problem for admins who're trying to optimse the system
> by tying RX interrupts together with TX interrupts for the most
> common traffic path.
>=20
> For example, if you're forwarding traffic between multiqueue NICs
> A and B, one would like to make it so that each queue on A goes
> to a fixed queue on B where the CPU of the RX queue IRQ handler on
> A is the same as the CPU of the TX queue IRQ handler on B.
>=20
> This can still be done with the randomness, but it is much more
> difficult.  Also if the randomness changes, we'd have to rejig
> the IRQ assignment.
>=20
> So can you think of a scenario where we really need this added
> protection?
>=20
jhash_1word(val, some_32bits_value) has a shuffle property we want to k=
eep.

Maybe we can add a boot parameter so that admins who're trying to
optimize their system can fix a given value (yet not known to outsiders=
)
for simple_tx_hashrnd. This way, they know next reboots will keep
same hash function.



