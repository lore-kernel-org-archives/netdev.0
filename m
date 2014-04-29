From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [net-next 03/15] i40evf: support ethtool RSS options
Date: Tue, 29 Apr 2014 13:35:29 +0100
Message-ID: <1398774929.3881.7.camel@deadeye.wl.decadent.org.uk>
References: <1398693158-2815-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1398693158-2815-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-iw46H4DTNEj6BWicf8xW"
Cc: davem@davemloft.net, Mitch A Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:49436 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933248AbaD2Mfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 08:35:45 -0400
In-Reply-To: <1398693158-2815-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-iw46H4DTNEj6BWicf8xW
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-04-28 at 06:52 -0700, Jeff Kirsher wrote:
[...]
> +/**
> + * i40evf_set_rss_hash_opt - Enable/Disable flow types for RSS hash
> + * @adapter: board private structure
> + * @cmd: ethtool rxnfc command
> + *
> + * Returns Success if the flow input set is supported.
> + **/
> +static int i40evf_set_rss_hash_opt(struct i40evf_adapter *adapter,
> +				   struct ethtool_rxnfc *nfc)
> +{
[...]
> +	case AH_ESP_V4_FLOW:
> +	case AH_V4_FLOW:
> +	case ESP_V4_FLOW:
> +	case SCTP_V4_FLOW:
> +		if ((nfc->data & RXH_L4_B_0_1) ||
> +		    (nfc->data & RXH_L4_B_2_3))
> +			return -EINVAL;
> +		hena |=3D ((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_OTHER);
> +		break;
> +	case AH_ESP_V6_FLOW:
> +	case AH_V6_FLOW:
> +	case ESP_V6_FLOW:
> +	case SCTP_V6_FLOW:
> +		if ((nfc->data & RXH_L4_B_0_1) ||
> +		    (nfc->data & RXH_L4_B_2_3))
> +			return -EINVAL;
> +		hena |=3D ((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_OTHER);
> +		break;

I'm not sure why these cases operate on 'hena' as
I40E_FILTER_PCTYPE_NONF_IPV{4,6}_OTHER are presumably always set in the
register.

> +	case IPV4_FLOW:
> +		hena |=3D ((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_OTHER) |
> +			((u64)1 << I40E_FILTER_PCTYPE_FRAG_IPV4);
> +		break;
> +	case IPV6_FLOW:
> +		hena |=3D ((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_OTHER) |
> +			((u64)1 << I40E_FILTER_PCTYPE_FRAG_IPV6);
> +		break;

These cases aren't validating that the user didn't ask for ports to be
included in the hash.  They also interact oddly with UDP flow hashing
configuration.  It seems to me that the I40E_FILTER_PCTYPE_FRAG_IPV{4,6}
bits ought to be controllable through one flow type only.

[...]
> +static int i40evf_get_rxfh_indir(struct net_device *netdev, u32 *indir)
> +{
> +	struct i40evf_adapter *adapter =3D netdev_priv(netdev);
> +	struct i40e_hw *hw =3D &adapter->hw;
> +	u32 hlut_val;
> +	int i, j;
> +
> +	for (i =3D 0, j =3D 0; i < I40E_VFQF_HLUT_MAX_INDEX; i++) {
[...]

Off by 1?

Ben.

--=20
Ben Hutchings
Q.  Which is the greater problem in the world today, ignorance or apathy?
A.  I don't know and I couldn't care less.

--=-iw46H4DTNEj6BWicf8xW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU1+clue/yOyVhhEJAQoCCA//T92MoptK6YYX7pSi2V/qr4Wkl5EyN08h
k9Z87iD0vLV1eU9M6TAXRGoC9XaWOB24mKSQirOfNxM+tRYNxmEYxGsTjBLo7YcR
r53zln4XQzheSkYUe/HWb0LHpUFfo15VNd5y6ARIAHIduNzTjZ0wcg14dOTo2aiw
VxIIYPAw2m4kKi2n3BeUhF4J6O7eP5TwQ3HW0sZojEkMDXnrF9WcI3h1Z5DTbW98
8G2iIOyDG383wNQGUtiHw1ijrsbELV9+1v88ZLx1UBetZYqw73r19EAn3yqwMuZv
EXqIfuVzyZrSlQnSJDOOpcDjxZFQOa9PPubQN11HeInmexihtSarSkD/56+Hd5OG
aEKFK7Tasku+z9fJiVouw9BQmdKUeSH78vBy+hgoO7KDtAr+YX0rXbYmuNpUQsxU
8PaC9rsE1jR/jlVcZAKqGZmSFS74ithvBA66kg1URcQHmB+5z9TRDbuJjUoBAvcs
Xp/02W+LjZtemUTfd7hU8Dj+GUasA6+lw8ieCWCtNHcGUXEDYJubdukPlX6Uv3Xm
jvfb69pG3IQTY6Ayh2wnHqjtw1EeAzI2cc4FrWBNhqKd/HYGJ9ZfYM4aGdM9PQh5
wd5kHhpH+l6GWd4m9D/BCflj+aP0WTVfumfwByGqWs3SJ/0jIkX0SQZppboEoZvX
pcV59xw5/5s=
=iT/P
-----END PGP SIGNATURE-----

--=-iw46H4DTNEj6BWicf8xW--
