From: Yann Dupont - Veille Techno <veilletechno-irts@univ-nantes.fr>
Subject: Re: [patch v2] qlcnic: fix a timeout loop
Date: Mon, 4 Jan 2016 14:19:57 +0100
Message-ID: <568A717D.6070309@univ-nantes.fr>
References: <20151215135616.GA18851@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: Dan Carpenter <dan.carpenter@oracle.com>,
	Dept-GELinuxNICDev@qlogic.com,
	Manish Chopra <manish.chopra@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtptls2-lmb.cpub.univ-nantes.fr ([193.52.103.111]:49033 "EHLO
	smtp-tls.univ-nantes.fr" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753238AbcADNZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 08:25:27 -0500
In-Reply-To: <20151215135616.GA18851@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/12/2015 14:56, Dan Carpenter a =E9crit :
> The problem here is that at the end of the loop we test for if
> idc->vnic_wait_limit is zero, but since idc->vnic_wait_limit-- is a
> post-op, it actually ends up set to (u8)-1.  I have fixed this by
> moving the decrement inside the loop.
>
> Fixes: 486a5bc77a4a ('qlcnic: Add support for 83xx suspend and resume=
=2E')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> v2: different color on the bikeshed
>
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c b/=
drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
> index be7d7a6..b1a452f 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
> @@ -246,7 +246,8 @@ int qlcnic_83xx_check_vnic_state(struct qlcnic_ad=
apter *adapter)
>   	u32 state;
>  =20
>   	state =3D QLCRDX(ahw, QLC_83XX_VNIC_STATE);
> -	while (state !=3D QLCNIC_DEV_NPAR_OPER && idc->vnic_wait_limit--) {
> +	while (state !=3D QLCNIC_DEV_NPAR_OPER && idc->vnic_wait_limit) {
> +		idc->vnic_wait_limit--;
>   		msleep(1000);
>   		state =3D QLCRDX(ahw, QLC_83XX_VNIC_STATE);
>   	}
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
Hi everybody, & Happy new year.

We're seeing very sporadic & rare kernel oops due to qlcnic, even with=20
latests kernels.
I only have 1 trace, which can be seen here https://paste2.org/4m8EGEG1

Others kernel oops (not recorded) showed different stack trace, but in=20
the end, problem was always in qlcnic_xmit_frame


Any chance this bug is corrected by this very patch or is this a totall=
y=20
different problem ?

Cheers,
Yann.
