From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH ethtool 2/3] ethtool: Regularise handling of offload
	flags
Date: Tue, 22 Feb 2011 22:17:43 +0100
Message-ID: <20110222211743.GA9935@rere.qmqm.pl>
References: <1298307282.2608.47.camel@bwh-desktop> <1298307548.2608.50.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:38860 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753119Ab1BVVRp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Feb 2011 16:17:45 -0500
Content-Disposition: inline
In-Reply-To: <1298307548.2608.50.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 21, 2011 at 04:59:08PM +0000, Ben Hutchings wrote:
> Use the new ETHTOOL_{G,S}FEATURES operations where available, and
> use the new structure and netif feature flags in any case.
[...]
> --- a/ethtool.c
> +++ b/ethtool.c
[...]
> +static int dump_offload(const struct ethtool_get_features_block *fea=
tures)
>  {
[...]
> +	u32 value;
> +	int i;
> +
> +	for (i =3D 0; i < ARRAY_SIZE(off_feature_def); i++) {
> +		value =3D off_feature_def[i].value;
> +		printf("%s: %s%s%s\n",
> +		       off_feature_def[i].long_name,
> +		       (features->active & value) ? "on" : "off",
> +		       (features->requested & ~features->active & value) ?
> +		       " [requested on]" : "",
> +		       (~features->available & value) ? " [unchangeable]" : "");
> +	}

This would be clearer if '[requested XXX]' part was shown only when the
offload's state is different than requested.

Best Regards,
Micha=B3 Miros=B3aw=20
