From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH] i40e: handle setting administratively set MAC address
 back to zero
Date: Sun, 25 Jun 2017 09:21:08 +0300
Message-ID: <20170625062108.GQ1248@mtr-leonro.local>
References: <20170623074624.32405-1-sassmann@kpanic.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="zj18g9eElA7rRQh+"
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        davem@davemloft.net, jeffrey.t.kirsher@intel.com
To: Stefan Assmann <sassmann@kpanic.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:41052 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751184AbdFYGVM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Jun 2017 02:21:12 -0400
Content-Disposition: inline
In-Reply-To: <20170623074624.32405-1-sassmann@kpanic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--zj18g9eElA7rRQh+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Jun 23, 2017 at 09:46:24AM +0200, Stefan Assmann wrote:
> When an administratively set MAC was previously set and should now be
> switched back to 00:00:00:00:00:00 the pf_set_mac flag did not get
> toggled back to false.
> As a result VFs were still treated as if an administratively set MAC was
> present.
>
> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
> index ecbe40e..af0ff61 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
> @@ -2764,7 +2764,6 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
>
>  	spin_unlock_bh(&vsi->mac_filter_hash_lock);
>
> -	dev_info(&pf->pdev->dev, "Setting MAC %pM on VF %d\n", mac, vf_id);
>  	/* program mac filter */
>  	if (i40e_sync_vsi_filters(vsi)) {
>  		dev_err(&pf->pdev->dev, "Unable to program ucast filters\n");
> @@ -2772,7 +2771,16 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
>  		goto error_param;
>  	}
>  	ether_addr_copy(vf->default_lan_addr.addr, mac);
> -	vf->pf_set_mac = true;
> +
> +	if (is_zero_ether_addr(mac)) {
> +		vf->pf_set_mac = false;
> +		dev_info(&pf->pdev->dev, "Removing MAC on VF %d\n", vf_id);
> +	} else {
> +		vf->pf_set_mac = true;
> +		dev_info(&pf->pdev->dev, "Setting MAC %pM on VF %d\n",
> +			 mac, vf_id);
> +	}
> +

It can be removed to be one line change, because I'm not sure that
dev_info prints are necessary here.
+	vf->pf_set_mac = is_zero_ether_addr(mac);

Thanks

>  	/* Force the VF driver stop so it has to reload with new MAC address */
>  	i40e_vc_disable_vf(pf, vf);
>  	dev_info(&pf->pdev->dev, "Reload the VF driver to make this change effective.\n");
> --
> 2.9.4
>

--zj18g9eElA7rRQh+
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllPVlQACgkQ5GN7iDZy
WKcZaw/7BvuZ0Qze88uKQ1OpSdpeOi7Opepxu48cLkrXR21CvtOqHaxJbXBHJW8k
QvoaIhMhvMcwAM/j7fOlS4msB6km8nd9ZEhdCqOceLAkIKN7/8b5ItwBy5fc6ym4
fsIiG6uxRGCaChzFcFYHwbeEiU1IWR6kiBAjjdIY4S/RhuDAQ4umuqHxwkr6NHFR
7QgRfvBzAIzG3dK2iFgTLg31fQ4SiSIePx9hFEcDHPxXLhVn5cOo4WX4Kz7Yqu4Z
0hu5u43KQYxSZztJ8xDpKWqdyNfPqDU0vi9Xw3eB0LKj2vxC2z4nZEfLmtt95Gek
XYALJTmVEfUwVsFLHqhsKxDLf5Nq4zKRA3tiGjyuXsNprWJEAJvQvFLkXh5lGT18
/oyE4tV3rIbekSixqNhoRJ7o4koRkBWiQcXtofHTcwWa3vr1Ddxn99nzptbKsVRf
XD8v9M92X1kp6wsEU6tyz0Dy3gd/yimshfTNzIV4BIKrBZsoxEUjam1c+DD4w9oI
nYced4QvRLRhYN124FgnnM0p5QZU2vNl60fbcEbZVEa0wgLuXwOIxmA2irJLcPwC
ogU1u9VXUlxTViU+kqqevVXjonkSzQCO6abdX/S6osOVQPXkQG9fGKBkAfFRIh0D
itWq65S4VlCJoQSu/VnyhBxPzh6wPQC88PNR+dqEk1RSfMVDoM4=
=JTM0
-----END PGP SIGNATURE-----

--zj18g9eElA7rRQh+--
