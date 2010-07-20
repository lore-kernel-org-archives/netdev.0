From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH 2/5] ixgbe: drop support for UDP in RSS
 hash generation
Date: Tue, 20 Jul 2010 18:39:37 +0200
Message-ID: <1279643977.2498.89.camel@edumazet-laptop>
References: <20100719235831.14112.14175.stgit@localhost.localdomain>
	 <20100719235925.14112.65890.stgit@localhost.localdomain>
	 <1279607980.2458.82.camel@edumazet-laptop>  <4C45CAC6.1050006@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"bphilips@novell.com" <bphilips@novell.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:43910 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761312Ab0GTQjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 12:39:41 -0400
Received: by wwf26 with SMTP id 26so1751933wwf.1
        for <netdev@vger.kernel.org>; Tue, 20 Jul 2010 09:39:40 -0700 (PDT)
In-Reply-To: <4C45CAC6.1050006@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 20 juillet 2010 =C3=A0 09:11 -0700, Alexander Duyck a =C3=A9cr=
it :

> The packets will still be hashed on source and destination IPv4/IPv6=20
> addresses.  The change just drops reading the UDP source/destination=20
> ports since in the case of fragmented packets they are not available =
and=20
> as such were being parsed as IPv4/IPv6 packets.  By making this chang=
e=20
> the queue selection is consistent between all packets in the UDP stre=
am.
>=20

Excellent, this is perfect IMHO.

> The only regression I would expect to see would be in testing between=
=20
> two fixed systems since the IP addresses of the two systems would be=20
> fixed and so running multiple flows between the two would yield the s=
ame=20
>   RSS hash for multiple UDP streams.  As long as multiple ip addresse=
s=20
> are used  you should see multiple RSS hashes generated and as such th=
e=20
> load should still be distributed.
>=20

Ack. Fortunately, one can still use RPS to spread load onto multiple
cpus in this case.

This until ixgpe fills skb->rxhash with a non null value.
If it happens one day, we shall remind _not_ filling it for UDP packets=
=2E

BTW, this reminds me a netdev discussion we had for bnx2x

http://www.kerneltrap.com/mailarchive/linux-netdev/2010/4/23/6275415/th=
read

And now, I understand why Toepliz hash doesnt use src port/dst port,
since this is not available on fragments, obviously...

Thanks !


