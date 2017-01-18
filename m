From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH for bnxt_re V4 13/21] RDMA/bnxt_re: Support QP verbs
Date: Wed, 18 Jan 2017 11:16:41 +0200
Message-ID: <20170118091641.GV32481@mtr-leonro.local>
References: <1482320530-5344-1-git-send-email-selvin.xavier@broadcom.com>
 <1482320530-5344-14-git-send-email-selvin.xavier@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="iskw6J4cuOvZ6IVF"
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, michael.chan@broadcom.com,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: Selvin Xavier <selvin.xavier@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:59088 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751275AbdARJRN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 04:17:13 -0500
Content-Disposition: inline
In-Reply-To: <1482320530-5344-14-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--iskw6J4cuOvZ6IVF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Dec 21, 2016 at 03:42:02AM -0800, Selvin Xavier wrote:
> This patch implements create_qp, destroy_qp, query_qp and modify_qp verbs.
>
> v2: Fixed sparse warnings
> v3: Splits __filter_modify_flags function to avoid nested switch cases.
>     Removes unwanted macros. Also, fix the endianness related issues
>     reported by sparse.
>
> Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
> Signed-off-by: Devesh Sharma <devesh.sharma@broadcom.com>
> Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
> Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
> Signed-off-by: Selvin Xavier <selvin.xavier@broadcom.com>
> ---

<snip>

> +
> +static u8 __from_ib_qp_type(enum ib_qp_type type)
> +{
> +	switch (type) {
> +	case IB_QPT_GSI:
> +		return CMDQ_CREATE_QP1_TYPE_GSI;
> +	case IB_QPT_RC:
> +		return CMDQ_CREATE_QP_TYPE_RC;
> +	case IB_QPT_UD:
> +		return CMDQ_CREATE_QP_TYPE_UD;
> +	case IB_QPT_RAW_ETHERTYPE:
> +		return CMDQ_CREATE_QP_TYPE_RAW_ETHERTYPE;
> +	default:
> +		return IB_QPT_MAX;
> +	}
> +}
> +

<snip>

> +static u8 __from_ib_qp_state(enum ib_qp_state state)
> +{
> +	switch (state) {
> +	case IB_QPS_RESET:
> +		return CMDQ_MODIFY_QP_NEW_STATE_RESET;
> +	case IB_QPS_INIT:
> +		return CMDQ_MODIFY_QP_NEW_STATE_INIT;
> +	case IB_QPS_RTR:
> +		return CMDQ_MODIFY_QP_NEW_STATE_RTR;
> +	case IB_QPS_RTS:
> +		return CMDQ_MODIFY_QP_NEW_STATE_RTS;
> +	case IB_QPS_SQD:
> +		return CMDQ_MODIFY_QP_NEW_STATE_SQD;
> +	case IB_QPS_SQE:
> +		return CMDQ_MODIFY_QP_NEW_STATE_SQE;
> +	case IB_QPS_ERR:
> +	default:
> +		return CMDQ_MODIFY_QP_NEW_STATE_ERR;
> +	}
> +}
> +
> +static enum ib_qp_state __to_ib_qp_state(u8 state)
> +{
> +	switch (state) {
> +	case CMDQ_MODIFY_QP_NEW_STATE_RESET:
> +		return IB_QPS_RESET;
> +	case CMDQ_MODIFY_QP_NEW_STATE_INIT:
> +		return IB_QPS_INIT;
> +	case CMDQ_MODIFY_QP_NEW_STATE_RTR:
> +		return IB_QPS_RTR;
> +	case CMDQ_MODIFY_QP_NEW_STATE_RTS:
> +		return IB_QPS_RTS;
> +	case CMDQ_MODIFY_QP_NEW_STATE_SQD:
> +		return IB_QPS_SQD;
> +	case CMDQ_MODIFY_QP_NEW_STATE_SQE:
> +		return IB_QPS_SQE;
> +	case CMDQ_MODIFY_QP_NEW_STATE_ERR:
> +	default:
> +		return IB_QPS_ERR;
> +	}
> +}
> +
> +static u32 __from_ib_mtu(enum ib_mtu mtu)
> +{
> +	switch (mtu) {
> +	case IB_MTU_256:
> +		return CMDQ_MODIFY_QP_PATH_MTU_MTU_256;
> +	case IB_MTU_512:
> +		return CMDQ_MODIFY_QP_PATH_MTU_MTU_512;
> +	case IB_MTU_1024:
> +		return CMDQ_MODIFY_QP_PATH_MTU_MTU_1024;
> +	case IB_MTU_2048:
> +		return CMDQ_MODIFY_QP_PATH_MTU_MTU_2048;
> +	case IB_MTU_4096:
> +		return CMDQ_MODIFY_QP_PATH_MTU_MTU_4096;
> +	default:
> +		return CMDQ_MODIFY_QP_PATH_MTU_MTU_2048;
> +	}
> +}
> +
> +static enum ib_mtu __to_ib_mtu(u32 mtu)
> +{
> +	switch (mtu & CREQ_QUERY_QP_RESP_SB_PATH_MTU_MASK) {
> +	case CMDQ_MODIFY_QP_PATH_MTU_MTU_256:
> +		return IB_MTU_256;
> +	case CMDQ_MODIFY_QP_PATH_MTU_MTU_512:
> +		return IB_MTU_512;
> +	case CMDQ_MODIFY_QP_PATH_MTU_MTU_1024:
> +		return IB_MTU_1024;
> +	case CMDQ_MODIFY_QP_PATH_MTU_MTU_2048:
> +		return IB_MTU_2048;
> +	case CMDQ_MODIFY_QP_PATH_MTU_MTU_4096:
> +		return IB_MTU_4096;
> +	default:
> +		return IB_MTU_2048;
> +	}
> +}

Why do you you need these functions? These translations to<->from look
redundant.

Thanks

--iskw6J4cuOvZ6IVF
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlh/MnkACgkQ5GN7iDZy
WKd/XQ/+OLPXXZmsDdpvvceyl64iL2S+GtR4aD4RRirBtY3++lYEMiDOLUVaZrlj
wPSkdII9oUGps3nvK6nS16M2EW5Ya+ZtuAPNFYv3zu/qtqgl/To5ZkY85xNzjb4v
VuD4kUcfqLbPh/GdrmkHo4CM6PZGdIsl08QeeV/vSbxX9eKiiae7Ouw+/WUzf6+1
rINP+jnizikk3LxLrQUVckqpozu0aroZnZlc1L536jDVFECiMnTNSS2Huyh0WvDZ
DAQ7NW2uRESPMCj4JyNlPUKwg6nQDDy2vIFtG+6R4uYuNl7lp138scEpRaEnLGd3
HwKdo5wtpqnfAPPZwp53D39aUrAdCJdgh2lpPBU+hRJcCS3HOQ37GGTuwazoSCzP
cWBJyf33wVmNEPpnCGohm1UPY4pB0y2fUdcg48ZoMBprismCvInGbwelj5Q8mutD
l6iwZ+9Nz/TcYd56b/dbefLEpyqQymMlgZO7o9VuGCAaPZtBxnVh1fE8HXOErpK8
2d4S+PZy8LG7z46Y6XNrF/L1Dka49Q4J/JxHvtpwzeoPAq91Nm0zG/3thckmIrmo
f3rUg+w/veSPIl3C36tAzO7rjBWuCW6cQITkoIh6t9ndFBrRlcOdgeG0rpjw+SzG
41TLi+zmeyT3xni0qkSJ+YJ041vaq+FpO1hFzsS6+cR+WQhFEkw=
=DOU9
-----END PGP SIGNATURE-----

--iskw6J4cuOvZ6IVF--
