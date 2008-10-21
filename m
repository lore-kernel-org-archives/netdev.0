From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] sky2: skb recycling
Date: Tue, 21 Oct 2008 14:42:37 +0200
Message-ID: <48FDCE3D.9050801@cosmosbay.com>
References: <20081020190922.7dd6510a@extreme>	<48FD6E8A.6060304@cosmosbay.com>	<18685.37380.34636.316536@robur.slu.se>	<48FD97AB.1040007@baidu.com> <18685.51303.285228.177350@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Terry <hanfang@baidu.com>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Robert Olsson <robert@robur.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp23.orange.fr ([193.252.22.30]:58237 "EHLO smtp23.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754913AbYJUMms convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 08:42:48 -0400
In-Reply-To: <18685.51303.285228.177350@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Olsson a =E9crit :
> Terry writes:
>  > Hi=20
>  >     yeah. In the forwarding scenario , skb recycling should boost =
the=20
>  > performance by avoiding slowpath slub alloc/free .But if  using=20
>  > multiqueue hardware and assigning proper  cpu affinities  could  m=
ake it=20
>  > always in the fastpath of slub  alloc/free, which is faster?
>=20
>  For perfect setup with monotone work like forwarding you can make th=
e skb=20
>  recycling a little faster.
>=20
>  If you have many active NIC's and the recycling list is per device t=
he situation
>  it's probably different...
>=20

I suspect all this skb recycling stuff in forwarding workloads is defea=
ted anyway...

By the copybreak feature... (RX_COPY_THRESHOLD =3D 256 for example on t=
g3)

Checking drivers/net/tg3.c, we can even see that in case of copying to =
a smaller skb,
we allocate it with a call to netdev_alloc_skb(), while it would be bet=
ter
to use a plain alloc_skb() ...




