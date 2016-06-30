From: Sathya Perla <sathya.perla@broadcom.com>
Subject: RE: [patch] be2net: signedness bug in be_msix_enable()
Date: Thu, 30 Jun 2016 16:52:56 +0530
Message-ID: <5e01e26fa672cf9686fdbc8d4448ffd2@mail.gmail.com>
References: <20160629143943.GA22818@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ajit Kumar Khaparde <ajit.khaparde@broadcom.com>,
	Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
	Somnath Kotur <somnath.kotur@broadcom.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20160629143943.GA22818@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Dan Carpenter [mailto:dan.carpenter@oracle.com]
>
> "num_vec" needs to be signed for the error handling to work.
>
> Fixes: e261768e9e39 ('be2net: support asymmetric rx/tx queue counts')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>
> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c
b/drivers/net/ethernet/emulex/benet/be_main.c
> index 1873c74..1f16e73 100644
> --- a/drivers/net/ethernet/emulex/benet/be_main.c
> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
> @@ -3251,8 +3251,9 @@ static void be_msix_disable(struct be_adapter
*adapter)
>
>  static int be_msix_enable(struct be_adapter *adapter)  {
> -	unsigned int i, num_vec, max_roce_eqs;
> +	unsigned int i, max_roce_eqs;
>  	struct device *dev = &adapter->pdev->dev;
> +	int num_vec;
>

Oops...thanks for catching this! This must go into net-next.

Acked-by: Sathya Perla <sathya.perla@broadcom.com>
