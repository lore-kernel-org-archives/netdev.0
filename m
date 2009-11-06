From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] Phonet: use rwlock for sockets list
Date: Fri, 06 Nov 2009 15:00:39 +0100
Message-ID: <4AF42C07.4050008@gmail.com>
References: <1257514891-18917-1-git-send-email-remi@remlab.net> <4AF42834.7010707@gmail.com> <65081524fbfeb975c842ebc79a8fb038@chewa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?B?UsOpbWkgRGVuaXMtQ291cm1vbnQ=?=
	<remi.denis-courmont@nokia.com>
To: =?UTF-8?B?UsOpbWkgRGVuaXMtQ291cm1vbnQ=?= <remi@remlab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38422 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752868AbZKFOAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 09:00:41 -0500
In-Reply-To: <65081524fbfeb975c842ebc79a8fb038@chewa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

R=C3=A9mi Denis-Courmont a =C3=A9crit :
> It seems better than a spinlock, assuming that sockets are
> created/destroyed more seldom than they receive packets. And then
> sk_for_each_rcu does not exist. I am sure there is a good reason for =
that,
> though I wouldn't know. I guess I should try to use RCU hlist_nulls t=
hen?
>=20

spin_lock()/spin_unlock() is faster than read_lock()/read_unlock(), unl=
ess
there is contention.  (two atomic ops instead of one)

So, unless you have a particular performance problem, it's actually
better to use a spinlock.

If you do have performance problem, a RCU conversion is better than rwl=
ock.
I can do RCU conversion if you ask me...
