From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PF_RING: Include in main line kernel?
Date: Thu, 15 Oct 2009 02:25:33 +0200
Message-ID: <4AD66BFD.8010100@gmail.com>
References: <a07586b0910141002m2a9f4466j412245fdae4e5372@mail.gmail.com>	<20091014123328.1ebe35ea@s6510>	<8B385E10-4BE2-48A6-BDE0-0AA1A603275E@ntop.org> <20091014.132756.231458769.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: deri@ntop.org, shemminger@vyatta.com, brad.doctor@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:49370 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761695AbZJOA0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 20:26:35 -0400
In-Reply-To: <20091014.132756.231458769.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Luca Deri <deri@ntop.org>
> Date: Wed, 14 Oct 2009 22:17:30 +0200
>=20
>> Another reason, is that having a hook in dev.c, device drivers can
>> pass PF_RING packets directly without going through the standard
>> kernel mechanisms. For instance I have developed some drivers that i=
f
>> they detect the presence of PF_RING, pass received packets directly =
to
>> PF_RING instead of going with NAPI.
>=20
> There is absolutely no reason to do this.
>=20
> If the existing infrastructure isn't good or fast enough,
> fix it, don't bypass it.

Indeed. IMHO PF_RING seems a huge pile of hacks to me, that would need
a lot of cleanup work before inclusion.

I had problems with past af_packet mmap implementation on ia32, because
not enough high order pages where available in lowmem.

"tcpdump -s 0" could trigger OOM conditions on loaded machines, not sur=
e
it is still the case after commit 719bfeaae8104fca4ca5d47c02592b08682f1=
4fa
(packet: avoid warnings when high-order page allocation fails)

If mmap() can only use 4K pages, are we still able to capture >4K packe=
ts ?

I'll check this.
