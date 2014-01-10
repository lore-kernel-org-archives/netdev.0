From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: Re: [RFC net-next 1/3] bonding: add infrastructure for an option API
Date: Fri, 10 Jan 2014 12:21:22 -0800
Message-ID: <7F4A3DF6-7DD5-4E11-986A-C090F02506A5@cumulusnetworks.com>
References: <1389359495-9700-1-git-send-email-nikolay@redhat.com> <1389359495-9700-2-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:47961 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258AbaAJUVo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 15:21:44 -0500
In-Reply-To: <1389359495-9700-2-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jan 10, 2014, at 5:11 AM, Nikolay Aleksandrov <nikolay@redhat.com> w=
rote:

> This patch adds the necessary basic infrastructure to support
> centralized and unified option manipulation API for the bonding. The =
new
> structure bond_option will be used to describe each option with its
> dependencies on modes which will be checked automatically thus removi=
ng a
> lot of duplicated code. Also automatic range checking is added for
> non-string options. Currently the option setting function requires RT=
NL to
> be acquired prior to calling it, since many options already rely on R=
TNL
> it seemed like the best choice to protect all against common race
> conditions.
>=20


> +/**
> + * bond_opt_parse - parse option value
> + * @tbl: an option's values[] table to parse against
> + * @bufarg: value to parse
> + * @retval: pointer where to store the parsed value
> + * @string: how to treat bufarg (as string or integer)
> + *
> + * This functions tries to extract the value from bufarg and check i=
f it's
> + * a possible match for the option. It shouldn't be possible to have=
 a non-NULL
> + * return with @retval being < 0.
> + */
> +struct bond_value_tbl *bond_opt_parse(const struct bond_option *opt,
> +				      void *bufarg, int *retval, bool string)
> +{
> +	char *buf, *p, valstr[BOND_MAX_MODENAME_LEN + 1] =3D { 0, };

Did you mean to use BOND_MAX_MODENAME_LEN here?  bond_options.h should =
have it=92s own define max value string len, I think.

> +	struct bond_value_tbl *tbl, *maxval =3D NULL, *ret =3D NULL;
> +	int valint =3D -1, i, rv;
> +
> +	tbl =3D opt->values;
> +	if (!tbl)
> +		goto out;
> +
> +	if (string) {
> +		buf =3D bufarg;
> +		for (p =3D (char *)buf; *p; p++)
> +			if (!(isdigit(*p) || isspace(*p)))
> +				break;

I think we lost a comment here from old code explaining eating whitespa=
ce and trailing newline.

>=20
> +struct bond_value_tbl {
> +	char *name;
> +	int value;

What if want a u64 value?

> +	u32 flags;
> +};

struct bond_value_tbl_entry ?  Or just struct bond_value?  tbl is a col=
lection of these, so it=92s weird to have tbl in name of item.

-scott
