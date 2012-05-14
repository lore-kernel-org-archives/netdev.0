From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2 1/6] netfilter: sanity checks on NFPROTO_NUMPROTO
Date: Mon, 14 May 2012 21:04:16 +0200
Message-ID: <20120514190416.GD14897@1984>
References: <1337003799-2517-1-git-send-email-alban.crequy@collabora.co.uk>
 <20120514144235.GE12992@1984>
 <20120514163949.37e614f4@rainbow.cbg.collabora.co.uk>
 <20120514170410.6c2f1c5b@rainbow.cbg.collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Vincent Sanders <vincent.sanders@collabora.co.uk>,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Alban Crequy <alban.crequy@collabora.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43835 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757208Ab2ENTET (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2012 15:04:19 -0400
Content-Disposition: inline
In-Reply-To: <20120514170410.6c2f1c5b@rainbow.cbg.collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 14, 2012 at 05:04:10PM +0100, Alban Crequy wrote:
> Le Mon, 14 May 2012 16:39:49 +0100,
> Alban Crequy <alban.crequy@collabora.co.uk> a =E9crit :
>=20
> > Le Mon, 14 May 2012 16:42:35 +0200,
> > Pablo Neira Ayuso <pablo@netfilter.org> a =E9crit :
> >=20
> > > On Mon, May 14, 2012 at 02:56:34PM +0100, Alban Crequy wrote:
> > > > With the NFPROTO_* constants introduced by commit 7e9c6e
> > > > ("netfilter: Introduce NFPROTO_* constants"), it is too easy to
> > > > confuse PF_* and NFPROTO_* constants in new protocols.
> > > >=20
> > > > Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
> > > > Reviewed-by: Javier Martinez Canillas
> > > > <javier.martinez@collabora.co.uk> Reviewed-by: Vincent Sanders
> > > > <vincent.sanders@collabora.co.uk> ---
> > > >  net/netfilter/core.c |    5 +++++
> > > >  1 files changed, 5 insertions(+), 0 deletions(-)
> > > >=20
> > > > diff --git a/net/netfilter/core.c b/net/netfilter/core.c
> > > > index e1b7e05..4f16552 100644
> > > > --- a/net/netfilter/core.c
> > > > +++ b/net/netfilter/core.c
> > > > @@ -67,6 +67,11 @@ int nf_register_hook(struct nf_hook_ops *reg=
)
> > > >  	struct nf_hook_ops *elem;
> > > >  	int err;
> > > > =20
> > > > +	if (reg->pf >=3D NFPROTO_NUMPROTO || reg->hooknum >=3D
> > > > NF_MAX_HOOKS) {
> > > > +		BUG();
> > > > +		return 1;
> > >=20
> > > nf_register_hook returns a negative value on error. -EINVAL can b=
e
> > > fine.
> >=20
> > Is it the patch you mean? Do you want me to do a series repost?
>=20
> Please disregard the previous patch, this is the correct one.
>=20
>=20
> From: Alban Crequy <alban.crequy@collabora.co.uk>
>=20
> netfilter: sanity checks on NFPROTO_NUMPROTO
>=20
> With the NFPROTO_* constants introduced by commit 7e9c6e ("netfilter:=
 Introduce
> NFPROTO_* constants"), it is too easy to confuse PF_* and NFPROTO_* c=
onstants
> in new protocols.
>=20
> Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
> ---
>  net/netfilter/core.c |    8 ++++++++
>  1 files changed, 8 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/netfilter/core.c b/net/netfilter/core.c
> index e1b7e05..7422989 100644
> --- a/net/netfilter/core.c
> +++ b/net/netfilter/core.c
> @@ -67,6 +67,14 @@ int nf_register_hook(struct nf_hook_ops *reg)
>  	struct nf_hook_ops *elem;
>  	int err;
> =20
> +	if (reg->pf >=3D NFPROTO_NUMPROTO || reg->hooknum >=3D NF_MAX_HOOKS=
) {
> +		WARN(reg->pf >=3D NFPROTO_NUMPROTO,
> +		     "netfilter: Invalid nfproto %d\n", reg->pf);
> +		WARN(reg->hooknum >=3D NF_MAX_HOOKS,
> +		     "netfilter: Invalid hooknum %d\n", reg->hooknum);

Then, better add two checkings. One to spot the first warning, and
another to spot the second.

I havent seen such a code in any netfilter code and I like that things
remain consistent.

> +		return -EINVAL;
> +	}
> +
>  	err =3D mutex_lock_interruptible(&nf_hook_mutex);
>  	if (err < 0)
>  		return err;
> --=20
> 1.7.2.5
>=20
