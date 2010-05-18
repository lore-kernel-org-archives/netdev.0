From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] netem: correlated loss generation (v3)
Date: Tue, 18 May 2010 07:19:21 +0200
Message-ID: <1274159961.2567.26.camel@edumazet-laptop>
References: <4BD84428.30904@uniroma2.it>  <20100517205621.036a06e0@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stefano Salsano <stefano.salsano@uniroma2.it>,
	David Miller <davem@davemloft.net>,
	Fabio Ludovici <fabio.ludovici@yahoo.it>,
	netdev@vger.kernel.org, netem@lists.linuxfoundation.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47155 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754285Ab0ERFTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 01:19:25 -0400
Received: by wyb39 with SMTP id 39so1030865wyb.19
        for <netdev@vger.kernel.org>; Mon, 17 May 2010 22:19:23 -0700 (PDT)
In-Reply-To: <20100517205621.036a06e0@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 17 mai 2010 =C3=A0 20:56 -0700, Stephen Hemminger a =C3=A9crit=
 :
> Subject: netem - revised correlated loss generator
>=20
> This is a patch originated with Stefano Salsano and Fabio Ludovici.
> It provides several alternative loss models for use with netem.
> There are two state machine based models and one table driven model.
>=20
> To simplify the original code:
>    * eliminated the debugging messages and statistics
>    * reformatted for clarity
>    * changed API to nested attribute relating to loss
>    * changed the table to always loop across bits
>    * only allocate parameters needed
>=20
> Still untested, for comment only...
> Should have tested version before 2.6.35 merge window closes.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


> +	if (loss[NETEM_LOSS_SEQUENCE]) {
> +		struct dlgtable *dlg;
> +		size_t len =3D nla_len(loss[NETEM_LOSS_SEQUENCE]);
> +
> +		dlg =3D kmalloc(sizeof(*dlg) + len, GFP_KERNEL);

No overflow check here, len comes from userland.

> +		if (dlg)
> +			goto nomem;
> +
> +		dlg->length =3D len * BITS_PER_LONG;
> +		dlg->index =3D 0;
> +		memcpy(dlg->sequence, nla_data(loss[NETEM_LOSS_SEQUENCE]), len);
> +
> +		kfree(q->dlg);
> +		q->dlg =3D dlg;
> +	}
> +
> +	q->loss_model =3D model;
> +	sch_tree_unlock(sch);


