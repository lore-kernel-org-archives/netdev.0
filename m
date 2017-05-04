From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH net 2/3] qed: Fix overriding of supported autoneg value.
Date: Thu, 4 May 2017 10:20:51 +0300
Message-ID: <20170504072051.GP22833@mtr-leonro.local>
References: <20170504065209.26106-1-sudarsana.kalluru@cavium.com>
 <20170504065209.26106-3-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="MiFvc8Vo6wRSORdP"
Cc: davem@davemloft.net, netdev@vger.kernel.org, Yuval.Mintz@cavium.com
To: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:38032 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751659AbdEDHUo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 03:20:44 -0400
Content-Disposition: inline
In-Reply-To: <20170504065209.26106-3-sudarsana.kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--MiFvc8Vo6wRSORdP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, May 03, 2017 at 11:52:08PM -0700, Sudarsana Reddy Kalluru wrote:
> Driver currently uses advertised-autoneg value to populate the
> supported-autoneg field. When advertised field is updated, user gets
> the same value for supported field. Supported-autoneg value need to be
> populated from the link capabilities value returned by the MFW.
>
> Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
> ---
>  drivers/net/ethernet/qlogic/qed/qed_dev.c  | 3 +++
>  drivers/net/ethernet/qlogic/qed/qed_main.c | 6 +++++-
>  drivers/net/ethernet/qlogic/qed/qed_mcp.h  | 1 +
>  3 files changed, 9 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
> index 5c6874a..bb70522 100644
> --- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
> +++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
> @@ -2536,6 +2536,9 @@ static int qed_hw_get_nvm_info(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
>  		DP_NOTICE(p_hwfn, "Unknown Speed in 0x%08x\n", link_temp);
>  	}
>
> +	p_hwfn->mcp_info->link_capabilities.default_speed_autoneg =
> +		link->speed.autoneg;
> +
>  	link_temp &= NVM_CFG1_PORT_DRV_FLOW_CONTROL_MASK;
>  	link_temp >>= NVM_CFG1_PORT_DRV_FLOW_CONTROL_OFFSET;
>  	link->pause.autoneg = !!(link_temp &
> diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
> index a5eef1a..b7ad36b 100644
> --- a/drivers/net/ethernet/qlogic/qed/qed_main.c
> +++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
> @@ -1372,7 +1372,7 @@ static void qed_fill_link(struct qed_hwfn *hwfn,
>
>  	/* TODO - at the moment assume supported and advertised speed equal */
>  	if_link->supported_caps = QED_LM_FIBRE_BIT;
> -	if (params.speed.autoneg)
> +	if (link_caps.default_speed_autoneg)
>  		if_link->supported_caps |= QED_LM_Autoneg_BIT;
>  	if (params.pause.autoneg ||
>  	    (params.pause.forced_rx && params.pause.forced_tx))
> @@ -1382,6 +1382,10 @@ static void qed_fill_link(struct qed_hwfn *hwfn,
>  		if_link->supported_caps |= QED_LM_Pause_BIT;
>
>  	if_link->advertised_caps = if_link->supported_caps;
> +	if (params.speed.autoneg)
> +		if_link->advertised_caps |= QED_LM_Autoneg_BIT;
> +	else
> +		if_link->advertised_caps &= ~QED_LM_Autoneg_BIT;
>  	if (params.speed.advertised_speeds &
>  	    NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_1G)
>  		if_link->advertised_caps |= QED_LM_1000baseT_Half_BIT |
> diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.h b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
> index 5ae35d6..937496d 100644
> --- a/drivers/net/ethernet/qlogic/qed/qed_mcp.h
> +++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
> @@ -61,6 +61,7 @@ struct qed_mcp_link_params {
>
>  struct qed_mcp_link_capabilities {
>  	u32 speed_capabilities;
> +	bool default_speed_autoneg;	/* In Mb/s */

bool variable in Mb/s ?????

>  };
>
>  struct qed_mcp_link_state {
> --
> 1.8.3.1
>

--MiFvc8Vo6wRSORdP
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlkK1lMACgkQ5GN7iDZy
WKdr5BAAyRR6+5lNmT7IK9qIarV6WzuCBScMga4KkfFhQfBUp/vb3V9wF6LOhkaX
0DyoCSvGCSNDKnggxj/42A+5BpAWh1u9n0lcYCdksi1YY7+w4nNaj7cUB/8AKi3E
vMvPT8Bqkz3oryJbdy7YRVmzRn3zXxQhN41KxuRZPOZJx+clS0qGxo6n3owq5Nq5
esS+F4cURRTDF0J0otqCXqU+f3gS6rF4fAa+EG+WyHQuCorikj0CuSoqUCe2oJoV
fhOq40ES7MQIBes0i6toC5zwuig0UQOH8F+MF48Rak0dUkzW1Nq3DatjHnv0eIw6
o96VX9KMHYXBRZtwM7mkVK2wOshAd25EGdzVGmfUETQec19T7mltrWPmuxdZvaAO
Nzo48id6FP7LGpUD0Q8mjZhhfCpLi5nCMS3IkJHsPMLhEp/R4mlSkhfyhgbOOCCt
UiUXYHAtAJfawVokx3nwHldG7JgnUIEsRAEpTfAcWySeUeY9X80kAZ/V1KFv0jo4
QD5zC+ivrEPZ98bx/zwxuc7lO57079zTS16aTmyv8WnghQHRWMI0cN+HgLc9xehO
e9L71qqtP/5u1qa5IRUkfdy3LFQJQZDb7h2i7GmciKTZL7bU+GbUDV0mcHY/rlvk
34xz8EEqQUkjL51xGTgqFEavmnf1IJ1TDtLd4jLHzmZ3MZdoaiE=
=K4yE
-----END PGP SIGNATURE-----

--MiFvc8Vo6wRSORdP--
