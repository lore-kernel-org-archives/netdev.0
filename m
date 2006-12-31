From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [KJ] [PATCH] net/core/flow.c: compare data with memcmp
Date: Sun, 31 Dec 2006 11:49:39 -0800
Message-ID: <20061231194939.GA14048@us.ibm.com>
References: <80ec54e90612310837y786fd764oc18bf37c8f0b2b8c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kernel-janitors@lists.osdl.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:54449 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932759AbWLaTt0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Dec 2006 14:49:26 -0500
To: Daniel =?iso-8859-1?Q?Marjam=E4ki?= <daniel.marjamaki@gmail.com>
Content-Disposition: inline
In-Reply-To: <80ec54e90612310837y786fd764oc18bf37c8f0b2b8c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 31.12.2006 [17:37:05 +0100], Daniel Marjam?ki wrote:
> From: Daniel Marjam=E4ki
> This has been tested by me.
> Signed-off-by: Daniel Marjam=E4ki <daniel.marjamaki@gmail.com>
> --- linux-2.6.20-rc2/net/core/flow.c	2006-12-27 09:59:56.000000000 +0=
100
> +++ linux/net/core/flow.c	2006-12-31 18:26:06.000000000 +0100
> @@ -144,29 +144,16 @@ typedef u32 flow_compare_t;
>=20
>  extern void flowi_is_missized(void);
>=20
> -/* I hear what you're saying, use memcmp.  But memcmp cannot make
> - * important assumptions that we can here, such as alignment and
> - * constant size.
> - */
>  static int flow_key_compare(struct flowi *key1, struct flowi *key2)
>  {
> -	flow_compare_t *k1, *k1_lim, *k2;
> -	const int n_elem =3D sizeof(struct flowi) / sizeof(flow_compare_t);
> -
>  	if (sizeof(struct flowi) % sizeof(flow_compare_t))
>  		flowi_is_missized();
>=20
> -	k1 =3D (flow_compare_t *) key1;
> -	k1_lim =3D k1 + n_elem;
> -
> -	k2 =3D (flow_compare_t *) key2;
> -
> -	do {
> -		if (*k1++ !=3D *k2++)
> -			return 1;
> -	} while (k1 < k1_lim);
> +	/* Number of elements to compare */
> +	const int n_elem =3D sizeof(struct flowi) / sizeof(flow_compare_t);
>=20
> -	return 0;
> +	/* Compare all elements in key1 and key2. */
> +	return memcmp(key1, key2, n_elem * sizeof(flow_compare_t));
>  }

Small nit, I don't think either of your comments make the code any
clearer than the code on its own, so drop them both.

Thanks,
Nish

--=20
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center
