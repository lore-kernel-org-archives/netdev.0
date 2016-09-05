From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH] RDS: Simplify code
Date: Mon, 5 Sep 2016 08:14:22 +0300
Message-ID: <20160905051422.GT21847@leon.nu>
References: <1472880809-29216-1-git-send-email-christophe.jaillet@wanadoo.fr>
 <20160904122049.GQ21847@leon.nu>
 <befa1a39-cfc5-721f-e39a-369436237b1c@wanadoo.fr>
 <20160904182354.GR21847@leon.nu>
 <73fc4be8-2530-b9ab-945b-887db6dca2a6@wanadoo.fr>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="e+JRL32uBeeWnrD4"
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <73fc4be8-2530-b9ab-945b-887db6dca2a6@wanadoo.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--e+JRL32uBeeWnrD4
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Sep 05, 2016 at 06:38:21AM +0200, Christophe JAILLET wrote:
> Le 04/09/2016 =E0 20:23, Leon Romanovsky a =E9crit :
> >On Sun, Sep 04, 2016 at 05:57:20PM +0200, Christophe JAILLET wrote:
> >>Le 04/09/2016 =E0 14:20, Leon Romanovsky a =E9crit :
> >>>On Sat, Sep 03, 2016 at 07:33:29AM +0200, Christophe JAILLET wrote:
> >>>>Calling 'list_splice' followed by 'INIT_LIST_HEAD' is equivalent to
> >>>>'list_splice_init'.
> >>>It is not 100% accurate
> >>>
> >>>list_splice(y, z)
> >>>INIT_LIST_HEAD(y)
> >>>
> >>>=3D=3D>
> >>>
> >>>if (!list_empty(y))
> >>>      __list_splice(y, z, z>next);
> >>>INIT_LIST_HEAD(y)
> >>>
> >>>and not
> >>>
> >>>if (!list_empty(y)) {
> >>>      __list_splice(y, z, z>next);
> >>>      INIT_LIST_HEAD(y)
> >>>}
> >>>
> >>>as list_splice_init will do.
> >>>
> >>You are right but if you dig further you will see that calling
> >>INIT_LIST_HEAD on an empty list is a no-op (AFAIK).
> >>And if this list was not already correctly initialized, then you would =
have
> >>some other troubles.
> >Thank you for the suggestion,
> >It looks like the code after that can be skipped in case of loop_conns
> >list is empty, the tmp_list will be empty too.
> >
> >174         list_for_each_entry_safe(lc, _lc, &tmp_list, loop_node) {
> >175                 WARN_ON(lc->conn->c_passive);
> >176                 rds_conn_destroy(lc->conn);
> >177         }
> Yes, but this would require some more code and test. This function doesn't
> seem to be in a hot path, so I'm not sure that the added complexity would
> worth it.
> It would require a new 'list_empty()' test and some code rearrangement.
>
> I suppose that testing for emptiness at the beginning or going through a
> list_for_each_entry_safe on a empty list (which will exit immediately and=
 do
> nothing) is more or less the same in term of speed. So keep the code simp=
le
> and readable.

I would expect one list_empty check at the beginning and return
immediately, but anyway it doesn't matter.

>
> CJ
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--e+JRL32uBeeWnrD4
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXzP8uAAoJEORje4g2clinquUQALBqKuu03zYEi9fjSBWJ7DSE
jnbiunocU4+1IX3Omnef0fPKLI3l6dDh5/E6u3T6UdfdYanhXAMXSD4ZYMbs54XO
hiRn1HUMyeVm7NgWW6aMnco/g/DRQTony/TSMjZ4KigV37ekRLDXWhBWxvAaLcfQ
AMwWdx0tXVPkVkZajd6f2bWGALe2ANPR2YgitCurKAJm6VJJFv9LY+AjJPiQoRAl
E8QVPp9JsP6no8DuHaQoOypKnJoSE3z+Mt8psU7Fw/eqfBtuIRP7BN91OSRx/y5y
ij2ydcmR0eyxkcpN/p64NSTAs+WOYGUOo2gl/ijPzalUypqE/+V0CYD+hjy09yL0
WFawAE6FCHw5nVFlVtHIfcBf9ClS4wa8J+T0iii70fHa5VUOnSNJzl4AMZecONbH
xKFg+dpooV+v+qbFcTxoI/SmJaho2cbBt3AYKNz1foF0ePrqgSV4vS3m7VLsQmcf
BLTPPqOckhvYxQL3uLbS3OPAEHOXlVzIX9AQ7uXb/iJjzOzi1TEEVDFDVLjARLJ0
JlexmXLJY5FbHSMcK9YsSBGjjmkhPeDeL3Ul6eeq/Cd/dAt7lvw+Kr0/rilsPWMc
lxAf5M0ZHCzXJJPjVDZBl8A0z6t8s6O0W5+CXggeS6TAf80XKChfmWFhy4ry4AzG
HXprZjaBZGoo2EdzAjQR
=1j/s
-----END PGP SIGNATURE-----

--e+JRL32uBeeWnrD4--
