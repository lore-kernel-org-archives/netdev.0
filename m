From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: Re: [PATCH 1/6] netfilter: sanity checks on NFPROTO_NUMPROTO
Date: Mon, 14 May 2012 16:39:49 +0100
Message-ID: <20120514163949.37e614f4@rainbow.cbg.collabora.co.uk>
References: <1337003799-2517-1-git-send-email-alban.crequy@collabora.co.uk>
	<20120514144235.GE12992@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Vincent Sanders <vincent.sanders@collabora.co.uk>,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120514144235.GE12992@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le Mon, 14 May 2012 16:42:35 +0200,
Pablo Neira Ayuso <pablo@netfilter.org> a =C3=A9crit :

> On Mon, May 14, 2012 at 02:56:34PM +0100, Alban Crequy wrote:
> > With the NFPROTO_* constants introduced by commit 7e9c6e
> > ("netfilter: Introduce NFPROTO_* constants"), it is too easy to
> > confuse PF_* and NFPROTO_* constants in new protocols.
> >=20
> > Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
> > Reviewed-by: Javier Martinez Canillas
> > <javier.martinez@collabora.co.uk> Reviewed-by: Vincent Sanders
> > <vincent.sanders@collabora.co.uk> ---
> >  net/netfilter/core.c |    5 +++++
> >  1 files changed, 5 insertions(+), 0 deletions(-)
> >=20
> > diff --git a/net/netfilter/core.c b/net/netfilter/core.c
> > index e1b7e05..4f16552 100644
> > --- a/net/netfilter/core.c
> > +++ b/net/netfilter/core.c
> > @@ -67,6 +67,11 @@ int nf_register_hook(struct nf_hook_ops *reg)
> >  	struct nf_hook_ops *elem;
> >  	int err;
> > =20
> > +	if (reg->pf >=3D NFPROTO_NUMPROTO || reg->hooknum >=3D
> > NF_MAX_HOOKS) {
> > +		BUG();
> > +		return 1;
>=20
> nf_register_hook returns a negative value on error. -EINVAL can be
> fine.

Is it the patch you mean? Do you want me to do a series repost?


=46rom: Alban Crequy <alban.crequy@collabora.co.uk>

netfilter: sanity checks on NFPROTO_NUMPROTO

With the NFPROTO_* constants introduced by commit 7e9c6e ("netfilter: I=
ntroduce
NFPROTO_* constants"), it is too easy to confuse PF_* and NFPROTO_* con=
stants
in new protocols.

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
Reviewed-by: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Reviewed-by: Vincent Sanders <vincent.sanders@collabora.co.uk>
---
 net/netfilter/core.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index e1b7e05..ac56c5b 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -67,6 +67,11 @@ int nf_register_hook(struct nf_hook_ops *reg)
 	struct nf_hook_ops *elem;
 	int err;
=20
+	if (reg->pf >=3D NFPROTO_NUMPROTO || reg->hooknum >=3D NF_MAX_HOOKS) =
{
+		WARN();
+		return -EINVAL;
+	}
+
 	err =3D mutex_lock_interruptible(&nf_hook_mutex);
 	if (err < 0)
 		return err;
--=20
1.7.2.5
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
