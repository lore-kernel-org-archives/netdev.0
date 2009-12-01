From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: seeing strange values for tcp sk_rmem_alloc
Date: Tue, 01 Dec 2009 17:58:17 +0100
Message-ID: <4B154B29.1030807@cosmosbay.com>
References: <4B15416A.2060202@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Linux kernel <linux-kernel@vger.kernel.org>
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47621 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754007AbZLAQ6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 11:58:37 -0500
In-Reply-To: <4B15416A.2060202@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Friesen a =E9crit :
> I'm hoping someone might be able to explain some odd behaviour that I=
'm
> seeing.
>=20
> Some of our developers wanted to be able to see how much of their rx
> socket buffer space was in use, so I added the following to sock_ioct=
l()
>=20
>=20
> 		case SIOCGSKRMEMALLOC:
> 		{
> 			int tmp;
> 			err =3D -EINVAL;
> 			if(!sock->sk)
> 				break;
> 			tmp =3D atomic_read(&sock->sk->sk_rmem_alloc);
> 			err =3D copy_to_user(argp, &tmp, sizeof(tmp));
> 			break;
> 		}
>=20
> To validate it, I wrote a testcase that opened a tcp socket, then loo=
ped
> sending 2k of data at a time to it and calling the above ioctl to che=
ck
> the sk_rmem_alloc value (without ever reading from the socket).
>=20
> The results were odd--I've copied them below.  Can anyone explain how=
 I
> can send 20K of data but sk_rmem_alloc still only shows 4.8K used, th=
en
> it suddenly jumps by a lot on the next packet to something that more
> reflects reality, then repeats that pattern again?  Is there some
> additional buffering happening somewhere in the TCP stack?
>=20

Me wondering why you think sk_rmem_alloc is about TX side.

Its used in RX path. rmem means ReadMemory.

You can send 1 Gbytes of data, and sk_rmem_alloc doesnt change, if your
TCP stream is unidirectionnal.

sk_rmem_alloc grows when skb are queued into receive queue
sk_rmem_alloc shrinks when application reads this receive queue.




