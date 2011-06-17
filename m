From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] gianfar v4: implement nfc
Date: Fri, 17 Jun 2011 08:33:41 -0700
Message-ID: <1308324821.16582.31.camel@Joe-Laptop>
References: <1308304412.15482.8.camel@DENEC1DT0191>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev <netdev@vger.kernel.org>,
	Sebastian =?ISO-8859-1?Q?P=F6hn?= <sebastian.poehn@belden.com>
To: Sebastian =?ISO-8859-1?Q?P=F6hn?=
	<sebastian.belden@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3078 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758349Ab1FQPdn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2011 11:33:43 -0400
In-Reply-To: <1308304412.15482.8.camel@DENEC1DT0191>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-06-17 at 11:53 +0200, Sebastian P=C3=B6hn wrote:
> This patch adds all missing functionalities for nfc except GRXFH.

Just some trivial comments.

> diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_etht=
ool.c
[]
> +static void gfar_swap(void *a, void *b, int size)
> +{
> +	u32 t1 =3D *(u32 *) a;
> +	u32 t2 =3D *(u32 *) (a + 4);
> +	u32 t3 =3D *(u32 *) (a + 8);
> +	u32 t4 =3D *(u32 *) (a + 12);
> +	*(u32 *) a =3D *(u32 *) b;
> +	*(u32 *) (a + 4) =3D *(u32 *) (b + 4);
> +	*(u32 *) (a + 8) =3D *(u32 *) (b + 8);
> +	*(u32 *) (a + 12) =3D *(u32 *) (b + 12);
> +	*(u32 *) b =3D t1;
> +	*(u32 *) (b + 4) =3D t2;
> +	*(u32 *) (b + 8) =3D t3;
> +	*(u32 *) (b + 12) =3D t4;
> +}

Doesn't this read better by casting a and b
to temporary pointers and using swap?

static void gfar_swap(void *a, void *b, int size)
{
	u32 *_a =3D a;
	u32 *_b =3D b;

	swap(_a[0], _b[0]);
	swap(_a[1], _b[1]);
	swap(_a[2], _b[2]);
	swap(_a[3], _b[3]);
}

[]

> +	mask_table =3D kzalloc(
> +			sizeof(struct gfar_mask_entry) * (MAX_FILER_CACHE_IDX
> +					/ 2 + 1), GFP_KERNEL);

	mask_table =3D kcalloc(MAX_FILER_CACHE_IDX / 2 + 1,
			     sizeof(struct gfar_mask_entry), GFP_KERNEL)

[]

> +			netdev_err(priv->ndev,
> +				"Adding this rule is not possible,"
> +				" because this flow-type is not supported"
> +				" by hardware!\n");

Could you review your logging messages for grammar
and spacing please.

=46or all these logging messages, you really should
ignore what is now an arbitrary 80 column limit and
not break the format string up on multiple lines.

It makes grep harder and when you write them, you don't
quite read them back to yourself normally.  You wouldn't
generally use a comma between possible and because.

			netdev_err(priv->ndev,
				   "Adding this rule is not possible because this flow-type is not =
supported by hardware!\n");

or maybe:

			netdev_err(priv->ndev,
				   "Rule not added.  Flow-type not supported by hardware!\n");

Maybe it should be:

	"Flow-type (%(some type)) not supported by hardware!\n",
	flow->some_type

> +				netdev_err(priv->ndev,
> +				"There is already an element on ID %d\n",
> +				flow->location);

I think it nicer to not align any function params
on indent level but where possible on open paren.

				netdev_err(priv->ndev,
					   "There is already an element on ID %d\n",
					   flow->location);

Aligning on indent level is confusing.
If you really need or want to to this, it's
better to change the indent level inwards
for extra long lines.

			netdev_err(priv->ndev,
"Adding this rule is not possible because this flow-type is not support=
ed by hardware!\n");

That way you can see if the line is too long for
a message logging form and should be shortened
somehow.


