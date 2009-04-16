From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: remove superfluous call to synchronize_net()
Date: Thu, 16 Apr 2009 20:43:24 +0200
Message-ID: <49E77C4C.5060508@cosmosbay.com>
References: <49E5FF5E.50409@cosmosbay.com> <20090415215454.GU6766@linux.vnet.ibm.com> <49E6C4C7.3050105@cosmosbay.com> <20090416155201.GF6924@linux.vnet.ibm.com> <49E756EB.7020003@cosmosbay.com> <20090416180231.GI6924@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:40753 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757178AbZDPSna convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 14:43:30 -0400
In-Reply-To: <20090416180231.GI6924@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul E. McKenney a =E9crit :
>=20
> Please add a comment where the synchronize_rcu() used to be explainin=
g why
> it is not needed.  The poor slob who copies your code isn't going to =
read
> theh Documentation/RCU, he is just going to expect it to magically wo=
rk.
>=20
> With the synchronize_rcu(), it does just magically work.  Without the
> synchronize_rcu(), you have to be careful.  Therefore, please add the
> comment saying that care is required.
>=20

Sorry Paul, I dont understand why I should put a comment to say :

/*
 * Dont need to use synchronize_net() or call_rcu() or msleep(100) or
 * whatever function here because bla bla ...
 */

We could add this comment in about 99% of all functions in linux kernel=
 ;)

I checked inet6_register_protosw(struct inet_protosw *p)
and it doesnt have this synchronize_rcu() neither the comment you advis=
e...

=46ollowing construct is obvious and should not be commented in code it=
self.

spin_lock_bh(&somelock);
list_for_each(..., ...) {
	if (some_condition) {
		list_add_rcu(..., ...)
or		rcu_assign_pointer(...)=20
		break;
	}
}
spin_unlock_bh(&somelock);

If it is not obvious, then it should be documented once in Documentatio=
n/RCU, since
we find hundred of similar code in kernel.

On the contrary, places where we *use* synchronize_{rcu|net}() should g=
et a comment
to explain why this is really necessary since this function can be a re=
al problem.

Thanks

