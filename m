From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next 1/3] uapi: add MACsec bits
Date: Tue, 08 Mar 2016 20:52:48 +0100
Message-ID: <1457466768.24270.24.camel@sipsolutions.net>
References: <cover.1456937772.git.sd@queasysnail.net>
	 <08d3b90c1577276ccbb8ae1794f8c9842df5222d.1456937772.git.sd@queasysnail.net>
	 (sfid-20160307_181300_785922_47902293)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>, stephen@networkplumber.org
To: Sabrina Dubroca <sd@queasysnail.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:39443 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751504AbcCHTwz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2016 14:52:55 -0500
In-Reply-To: <08d3b90c1577276ccbb8ae1794f8c9842df5222d.1456937772.git.sd@queasysnail.net> (sfid-20160307_181300_785922_47902293)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-03-07 at 18:12 +0100, Sabrina Dubroca wrote:

> +++ b/include/uapi/linux/if_macsec.h

Some bits of documentation in this file, regarding all the various
operations and attributes, might be nice. At least the netlink types?

E.g., given this:

> +#define DEFAULT_CIPHER_NAME "GCM-AES-128"
> +#define DEFAULT_CIPHER_ID=C2=A0=C2=A0=C2=A00x0080020001000001ULL
> +#define DEFAULT_CIPHER_ALT=C2=A0=C2=A00x0080C20001000001ULL

> +enum macsec_attrs {
[...]
> +	MACSEC_ATTR_CIPHER_SUITE,

should that be the ID, the alternate ID, or the string?

> +	MACSEC_ATTR_ICV_LEN,
> +	MACSEC_TXSA_LIST,
> +	MACSEC_RXSC_LIST,
> +	MACSEC_TXSC_STATS,
> +	MACSEC_SECY_STATS,
> +	MACSEC_ATTR_PROTECT,

This seems a bit inconsistent, MACSEC_ATTR_* vs. MACSEC_*?

> +enum macsec_sa_list_attrs {
> +	MACSEC_SA_LIST_UNSPEC,
> +	MACSEC_SA,
> +	__MACSEC_ATTR_SA_LIST_MAX,
> +	MACSEC_ATTR_SA_LIST_MAX =3D __MACSEC_ATTR_SA_LIST_MAX - 1,
> +};

Again, without documentation, it seems odd to have an enum with just a
single useful entry? If you just wanted an array you don't need this at
all? The netlink nesting properties could be specified somewhere.

> +enum macsec_rxsc_list_attrs {
> +	MACSEC_RXSC_LIST_UNSPEC,
> +	MACSEC_RXSC,

similarly here

> +enum macsec_rxsc_attrs {
> +	MACSEC_ATTR_SC_UNSPEC,
> +	/* use the same value to allow generic helper function, see
> +	=C2=A0* get_*_from_nl in drivers/net/macsec.c */
> +	MACSEC_ATTR_SC_IFINDEX =3D MACSEC_ATTR_IFINDEX,
> +	MACSEC_ATTR_SC_SCI =3D MACSEC_ATTR_SCI,

This seems odd, this must be nested inside the top-level attributes
since it's a single genl family, so why not use the top-level
attributes to start with?

If you need multiple you can use dump with multiple messages.

> +enum macsec_sa_attrs {
> +	MACSEC_ATTR_SA_UNSPEC,
> +	/* use the same value to allow generic helper function, see
> +	=C2=A0* get_*_from_nl in drivers/net/macsec.c */
> +	MACSEC_ATTR_SA_IFINDEX =3D MACSEC_ATTR_IFINDEX,
> +	MACSEC_ATTR_SA_SCI =3D MACSEC_ATTR_SCI,

likewise here

> +enum validation_type {
> +	MACSEC_VALIDATE_DISABLED =3D 0,
> +	MACSEC_VALIDATE_CHECK =3D 1,
> +	MACSEC_VALIDATE_STRICT =3D 2,
> +	__MACSEC_VALIDATE_MAX,
> +};
> +#define MACSEC_VALIDATE_MAX (__MACSEC_VALIDATE_MAX - 1)

everywhere else you put that into the enum, why not here?

> +struct macsec_rx_sc_stats {
> +	__u64 InOctetsValidated;
> +	__u64 InOctetsDecrypted;
> +	__u64 InPktsUnchecked;
> +	__u64 InPktsDelayed;
> +	__u64 InPktsOK;
> +	__u64 InPktsInvalid;
> +	__u64 InPktsLate;
> +	__u64 InPktsNotValid;
> +	__u64 InPktsNotUsingSA;
> +	__u64 InPktsUnusedSA;
> +};

It might be worth splitting those into attributes so that, if some
hardware offload can't provide all of the counters in the future, they
can just be left out of the netlink message?

johannes
