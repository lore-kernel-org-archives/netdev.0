From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [patch net-next RFC 07/12] dsa: implement ndo_swdev_get_id
Date: Thu, 21 Aug 2014 09:38:09 -0700
Message-ID: <1408639089.13073.0.camel@deadeye.wl.decadent.org.uk>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
	 <1408637945-10390-8-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-5KPflYU7E8gDjAfuFdMc"
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:48635 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751857AbaHUQic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2014 12:38:32 -0400
In-Reply-To: <1408637945-10390-8-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-5KPflYU7E8gDjAfuFdMc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-08-21 at 18:19 +0200, Jiri Pirko wrote:
[...]
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
> @@ -171,6 +171,19 @@ static int dsa_slave_ioctl(struct net_device *dev, s=
truct ifreq *ifr, int cmd)
>  	return -EOPNOTSUPP;
>  }
> =20
> +static int dsa_slave_swdev_get_id(struct net_device *dev,
> +				  struct netdev_phys_item_id *psid)
> +{
> +	struct dsa_slave_priv *p =3D netdev_priv(dev);
> +	struct dsa_switch *ds =3D p->parent;
> +	u64 tmp =3D (u64) ds;
> +
> +	/* TODO: add more sophisticated id generation */
> +	memcpy(&psid->id, &tmp, sizeof(tmp));
[...]

Right, you must not expose kernel addresses to userland.

Ben.

--=20
Ben Hutchings
If at first you don't succeed, you're doing about average.

--=-5KPflYU7E8gDjAfuFdMc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAU/Ygdue/yOyVhhEJAQoBlw//cAuMzmvIW6KL4HAqX4MhJQQsa1Ed/dpf
VGKe6GxyIbvu7Q6h2AFULI28vbYyuYBvI2CO95cOGuPWbuvFRAUqEce/ibqYo/wy
bIw8wGuj69Isbdj31+bu/Drjjo/p1LB9fNGOt1aktUjkZGf0Zog/kwSplMHKpq/2
/DSipa6kCBoMI7GFMjEkl9jF/TTEwQX1pP7jZzPNJik/VQiR7lF7UH1X2KdorPS+
uSAfVyurhxLbdx5Ieqh1k29FWf5yDcjxfq8RLnlS7AcN4v0LvvjngdQaUklpyMPf
fIKWBnYmOXwdC1oKAFUtq7vfVAGALaB7nrdbB0gz7eJ/mtE9ozcEj6+0rcrJ/Itg
OwPbgc08vVySOA+aoOvHU8FeZqpxoP7elh5F0/dqo61V0I48PnmevDulSJklfSnw
H8cQzddZ9RzzSet+EXweNDlXVQ9FPaWpvcAqcT/afWy7NmBTAHqnZEJB3xWVuWXx
sNizRb2oKq/6/Q+2us8MvCvWyEd3096xMmyUI3xkZ8t3ILE04Xij27t8z0jBzp/5
wX9/8a5lHb/FjuXCz61NjfBNMDx6O4kUFm6km98ABDzmm1rGAWYMooqpZpRblksf
D4PCGsDMbu/fZ1DdmhQCknIRCayZurceZqZGJKkzuaCOaOIDla4gXgTl+MwbjlJc
e8sDRad5QAo=
=llLe
-----END PGP SIGNATURE-----

--=-5KPflYU7E8gDjAfuFdMc--
