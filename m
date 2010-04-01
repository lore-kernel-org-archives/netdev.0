From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netlabel: Fix several rcu_dereference() calls used
 without RCU read locks
Date: Thu, 01 Apr 2010 22:56:47 +0200
Message-ID: <1270155407.2192.5.camel@edumazet-laptop>
References: <20100401204357.9795.80383.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:58474 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233Ab0DAU4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 16:56:52 -0400
Received: by bwz1 with SMTP id 1so1159515bwz.21
        for <netdev@vger.kernel.org>; Thu, 01 Apr 2010 13:56:50 -0700 (PDT)
In-Reply-To: <20100401204357.9795.80383.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 01 avril 2010 =C3=A0 16:43 -0400, Paul Moore a =C3=A9crit :
> The recent changes to add RCU lock verification to rcu_dereference() =
calls
> caught out a problem with netlbl_unlhsh_hash(), see below.
>=20
>  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
>  [ INFO: suspicious rcu_dereference_check() usage. ]
>  ---------------------------------------------------
>  net/netlabel/netlabel_unlabeled.c:246 invoked rcu_dereference_check(=
)
>  without protection!
>=20
> This patch fixes this problem as well as others like it in the NetLab=
el
> code.  Also included in this patch is the identification of future wo=
rk
> to eliminate the RCU read lock in netlbl_domhsh_add(), but in the int=
erest
> of getting this patch out quickly that work will happen in another pa=
tch
> to be finished later.
>=20
> Thanks to Eric Dumazet and Paul McKenney for their help in understand=
ing
> the recent RCU changes.
>=20
> Signed-off-by: Paul Moore <paul.moore@hp.com>
> Reported-by: David Howells <dhowells@redhat.com>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> ---
>  net/netlabel/netlabel_domainhash.c |   28 ++++++++++-----
>  net/netlabel/netlabel_unlabeled.c  |   66 ++++++++++----------------=
----------
>  2 files changed, 37 insertions(+), 57 deletions(-)
>=20

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks Paul


