From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [net-next 03/16] i40evf: Support RSS option in ethtool
Date: Mon, 17 Mar 2014 18:53:31 +0000
Message-ID: <1395082411.22343.4.camel@deadeye.wl.decadent.org.uk>
References: <1395060316-16897-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1395060316-16897-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ic5Z9dsXvFNbLpzlzNtE"
Cc: davem@davemloft.net, Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:49658 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750706AbaCQSxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 14:53:41 -0400
In-Reply-To: <1395060316-16897-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ic5Z9dsXvFNbLpzlzNtE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-03-17 at 05:45 -0700, Jeff Kirsher wrote:
> From: Mitch Williams <mitch.a.williams@intel.com>
>=20
> Add support for viewing and modifying RSS hash options and RSS hash
> look-up table programming through ethtool. Because the lookup table is
> so small for the VFs (only 16 registers), we don't bother to maintain a
> shadow table in memory, we just read and write the registers directly.
[...]
> +static int i40evf_get_rss_hash_opts(struct i40evf_adapter *adapter,
> +				    struct ethtool_rxnfc *cmd)
> +{
> +	cmd->data =3D 0;
> +
> +	/* Report default options for RSS on i40e */

But you're allowing them to be changed from the defaults, so this is
wrong.

[...]
> +static int i40evf_set_rxfh_indir(struct net_device *netdev, const u32 *i=
ndir)
> +{
> +	struct i40evf_adapter *adapter =3D netdev_priv(netdev);
> +	struct i40e_hw *hw =3D &adapter->hw;
> +	u32 hlut_val;
> +	int i, j;
> +
> +	/* Verify user input. */
> +	for (i =3D 0; i < (I40E_VFQF_HLUT_MAX_INDEX + 1) * 4; i++) {
> +		if (indir[i] >=3D adapter->vsi_res->num_queue_pairs)
> +			return -EINVAL;
> +	}
[...]

ethtool_set_rxfh_indir() does this validation so you don't have to.
(This wasn't true originally so you'll need to keep it in compatibility
code for your OOT driver.)

Ben.

--=20
Ben Hutchings
I'm always amazed by the number of people who take up solipsism because
they heard someone else explain it. - E*Borg on alt.fan.pratchett

--=-ic5Z9dsXvFNbLpzlzNtE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUydEq+e/yOyVhhEJAQqs4RAAzPlZianAo6V6Pv/ygecVZ0OmOdf+FgTX
gomTjgvyq3NlfRymRVbdaN1vmNoPkTt41P0UboURj7JMRnKYAfH1HNv8apSFJogE
2o4jqtobdx4UIr4ZY3a++3HIu7DqgRQqPKCLjEEFLvQVxlX2/sAu84qxiEEdFvW8
AhiTuH6wOjj3ozMRC7RrbHjukQ1kgapAsbQQkrh6Lhx29YCOAVJbg338ZcMhl/zM
ZTSzrn7vfiCLpgYRPvFMaMAcBI+O/AO0NPgCgc3FPs2uvgdUtdJQ1+YB8XUJTv+L
wpXX96ypF6QZQnJ4dgVQwpYJ0fo2VvSuB1l7ERQC7QUpVI21ilsUXLxHKzTysX+O
A8zygAnZDtJnJnTWoeXjWxEDteopO939rL4s5zhOGb2GrC0x51qy65n/dxvJpz4o
2Eq47oMmWVcuK2aAx2HukYxJgWCuhRWOdRFJcSO8tijl11DTYw0/ojUJB1AZuL8q
GJ8yjWFuD6O9hWp+EZo0qNvxIS4u6TjHKPKC6a7D7V6R/2GeAfdwZLsZ0oXpwOrr
j9Xd4LZ6AOudJy76PXtX1elBG+GWBeK+iRW5Zq3oEUasCUIQBhVnwIvKVSkrt17V
04LONKOH7sxT/lpxOry5fnmfDIu2D6Q4TrErOHNEYVJiKliXLSz0k8iUkGAG0p8h
CM5GJLTPr/w=
=1lLQ
-----END PGP SIGNATURE-----

--=-ic5Z9dsXvFNbLpzlzNtE--
