From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: What protects rcu_dereference() in __sk_free()?
Date: Sat, 16 Jan 2010 09:55:34 +0100
Message-ID: <4B517F06.5000008@gmail.com>
References: <20100114184107.GA17245@linux.vnet.ibm.com> <4B50043D.9090205@gmail.com> <20100115195153.GA6188@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dim@openvz.org, netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35794 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752137Ab0APIzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jan 2010 03:55:44 -0500
In-Reply-To: <20100115195153.GA6188@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/01/2010 20:51, Paul E. McKenney a =E9crit :
>=20
> Thank you for the info, Eric!
>=20
> One option would be to remove the rcu_dereference() from __sk_free().
> Given that it was there, my thought would be to make it read as follo=
ws:
>=20
> 	filter =3D rcu_dereference_check(sk->sk_filter,
> 				       atomic_read(&sk->sk_wmem_alloc) =3D=3D 0);
>=20
> This approach would have the benefit of potentially catching some rac=
e
> conditions if built with CONFIG_PROVE_RCU.  Does this seem reasonable=
 to
> you?

Thats a good suggestion, this documents the thing with no runtime cost.

Thanks
