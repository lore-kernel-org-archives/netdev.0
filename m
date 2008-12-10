From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] replace deprecated RW_LOCK_UNLOCKED in net/dccp/proto.c
Date: Wed, 10 Dec 2008 19:33:35 +0100
Message-ID: <49400B7F.7040607@cosmosbay.com>
References: <alpine.DEB.1.10.0812101314460.11805@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:46483 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757943AbYLJSeu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 13:34:50 -0500
In-Reply-To: <alpine.DEB.1.10.0812101314460.11805@gandalf.stny.rr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cced netdev

Steven Rostedt a =E9crit :
> The following patch is in:
>=20
>   git://git.kernel.org/pub/scm/linux/kernel/git/rostedt/linux-2.6-tra=
ce.git
>=20
>     branch: cleanups
>=20
>=20
> Steven Rostedt (1):
>       replace deprecated RW_LOCK_UNLOCKED in net/dccp/proto.c
>=20
> ----
>  net/dccp/proto.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> ---------------------------
> commit 3e1de819261b68a48b09719694c7e3579a8e4186
> Author: Steven Rostedt <srostedt@redhat.com>
> Date:   Wed Dec 10 12:49:47 2008 -0500
>=20
>     replace deprecated RW_LOCK_UNLOCKED in net/dccp/proto.c
>    =20
>     Impact: clean up
>    =20
>     RW_LOCK_UNLOCKED has been deprecated and superseded by
>     __RW_LOCK_UNLOCKED(name).  This patch removes one of the last
>     remaining users of it.
>    =20
>     Signed-off-by: Steven Rostedt <srostedt@redhat.com>
>=20
> diff --git a/net/dccp/proto.c b/net/dccp/proto.c
> index d0bd348..e6e54a7 100644
> --- a/net/dccp/proto.c
> +++ b/net/dccp/proto.c
> @@ -45,7 +45,7 @@ atomic_t dccp_orphan_count =3D ATOMIC_INIT(0);
>  EXPORT_SYMBOL_GPL(dccp_orphan_count);
> =20
>  struct inet_hashinfo __cacheline_aligned dccp_hashinfo =3D {
> -	.lhash_lock	=3D RW_LOCK_UNLOCKED,
> +	.lhash_lock	=3D __RW_LOCK_UNLOCKED(dccp_hashinfo.lhash_lock),
>  	.lhash_users	=3D ATOMIC_INIT(0),
>  	.lhash_wait =3D __WAIT_QUEUE_HEAD_INITIALIZER(dccp_hashinfo.lhash_w=
ait),
>  };
> --

Hum... this rwlock doesnt exist anymore on net-next-2.6, all this stuff
was converted to RCU for upcoming 2.6.29

struct inet_hashinfo dccp_hashinfo;
EXPORT_SYMBOL_GPL(dccp_hashinfo);

I guess such a patch wont ease David job when 2.6.29 merge window opens


