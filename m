From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: RE: [patch] qlcnic: dcb: a couple off by one bugs
Date: Mon, 3 Mar 2014 09:12:50 +0000
Message-ID: <290BEC245535C3449143D5D84900EEF78CDF93D1@avmb3.qlogic.org>
References: <20140301135436.GB23929@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Dept-HSG Linux NIC Dev <Dept-HSGLinuxNICDev@qlogic.com>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20140301135436.GB23929@elgon.mountain>
Content-Language: en-US
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: dept_hsg_linux_nic_dev-bounces@qlclistserver.qlogic.com
> [mailto:dept_hsg_linux_nic_dev-bounces@qlclistserver.qlogic.com] On
> Behalf Of Dan Carpenter
> Sent: Saturday, March 01, 2014 7:25 PM
> To: Shahed Shaikh
> Cc: Dept-HSG Linux NIC Dev; kernel-janitors@vger.kernel.org; netdev
> Subject: [patch] qlcnic: dcb: a couple off by one bugs
> 
> The ->tc_cfg[] array has QLC_DCB_MAX_TC (8) elements so the check is
> off by one.  These functions are always called with valid values though
> so it doesn't affect how the code works.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
> b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
> index 77f1bce432d2..7d4f54912bad 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
> @@ -807,7 +807,7 @@ qlcnic_dcb_get_pg_tc_cfg_tx(struct net_device
> *netdev, int tc, u8 *prio,
>  	    !type->tc_param_valid)
>  		return;
> 
> -	if (tc < 0 || (tc > QLC_DCB_MAX_TC))
> +	if (tc < 0 || (tc >= QLC_DCB_MAX_TC))
>  		return;
> 
>  	tc_cfg = &type->tc_cfg[tc];
> @@ -843,7 +843,7 @@ static void qlcnic_dcb_get_pg_bwg_cfg_tx(struct
> net_device *netdev, int pgid,
>  	    !type->tc_param_valid)
>  		return;
> 
> -	if (pgid < 0 || pgid > QLC_DCB_MAX_PG)
> +	if (pgid < 0 || pgid >= QLC_DCB_MAX_PG)
>  		return;
> 
>  	pgcfg = &type->pg_cfg[pgid];

Acked-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
