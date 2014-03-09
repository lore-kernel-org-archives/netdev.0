From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [net-next 03/13] i40e: Flow Director sideband accounting
Date: Sun, 09 Mar 2014 18:35:00 +0000
Message-ID: <1394390100.15968.9.camel@deadeye.wl.decadent.org.uk>
References: <1394079704-1108-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1394079704-1108-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-MA/q6hBZUtyW9BmL3BKO"
Cc: davem@davemloft.net,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Catherine Sullivan <catherine.sullivan@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51160 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751818AbaCISfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 14:35:09 -0400
In-Reply-To: <1394079704-1108-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-MA/q6hBZUtyW9BmL3BKO
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-03-05 at 20:21 -0800, Jeff Kirsher wrote:
[...]
> +static int i40e_get_ethtool_fdir_entry(struct i40e_pf *pf,
> +                                      struct ethtool_rxnfc *cmd)
> +{
> +       struct ethtool_rx_flow_spec *fsp =3D
> +                       (struct ethtool_rx_flow_spec *)&cmd->fs;
> +       struct i40e_fdir_filter *rule =3D NULL;
> +       struct hlist_node *node2;
> +
> +       /* report total rule count */
> +       cmd->data =3D pf->hw.fdir_shared_filter_count +
> +                   pf->fdir_pf_filter_count;

The value of the data field is not defined for ETHTOOL_GRXCLSRULE, so
don't set it here.

[...]
>  	case ETHTOOL_GRXCLSRLCNT:
> -		cmd->rule_cnt =3D 10;
> +		cmd->rule_cnt =3D pf->fdir_pf_active_filters;
>  		ret =3D 0;
>  		break;
[...]

However, ETHTOOL_GRXCLSRLCNT *should* set the data field consistently
with ETHTOOL_GRXCLSRLALL.

Ben.

--=20
Ben Hutchings
I say we take off; nuke the site from orbit.  It's the only way to be sure.

--=-MA/q6hBZUtyW9BmL3BKO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUxy0VOe/yOyVhhEJAQom6g/+JHCpE2rXRQ4I2YugtJPjjTk71dj6p5aJ
mnQyd9kQMwf/wvaUkNhV2GWK8fcHzJcWvv0dzL27HlNATMxF2QeeCtBWY2VPfRbb
SHAkzZqDFze8fWQPwqWyZhw7TwynViBuvPpjDpHQxsKe0n8WowL9FqwZ4x003DOU
F8MD+455dVX2Hipdok/SYaXGIUswMF+7Sg2OVasrVoqdBtDbc+RW1+YCHI1EHIKc
2LrTNym2yD7jOrLwlBrHo4wprZceMLrKIjXyl8MpiV2H2AT2yB7Pr3h05ZurEvFO
AUOA0sru28EMNsiEI0qsKyu5F2cOULOJEOc1tHplg+9J2gCxWKiyzAmjFDiognnz
DxJgDBnCxmaaNe6MMgmFKwbQrDVYi5SJrDJ/TcHyZ7X/ccPS8WZqaZbT+g9pHSTo
3YZDJwEehU71pYLL3BrJHfk6KUT43gOnjInUeyee5EPZv/2RyRe7rKlkULaamQJM
m4d39QZAqlI/BuZ/i6nwpYyaD9BfG6OFv3Uutb25qXVyBbT/Rry4FFWbBqb5RvLE
1lBjPdyD2XWu25fpfgpoOAlrfNQsRwffwNl4+5aqdExLGdFHBsmMze6sg+MFysgE
KgS6sMpVG0IYJVHgOcyRQRfBMXt+tewnING+w6zlR/63tAy3KZ2LS3rgoQiquaeY
IJrPGe0jT90=
=Bphz
-----END PGP SIGNATURE-----

--=-MA/q6hBZUtyW9BmL3BKO--
