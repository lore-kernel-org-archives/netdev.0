From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH][net-next] qtnfmac: fix uninitialized return code in ret
Date: Thu, 22 Jun 2017 08:10:41 +0300
Message-ID: <20170622051041.6vclukrzlq4zbdhm@mwanda>
References: <20170621132530.11937-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Igor Mitsyanko <imitsyanko@quantenna.com>,
        Avinash Patil <avinashp@quantenna.com>,
        Sergey Matyukevich <smatyukevich@quantenna.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        "David S . Miller" <davem@davemloft.net>,
        Bindu Therthala <btherthala@quantenna.com>,
        Kamlesh Rath <krath@quantenna.com>,
        Sergei Maksimenko <smaksimenko@quantenna.com>,
        Johannes Berg <johannes.berg@intel.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:29047 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751139AbdFVFLM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 01:11:12 -0400
Content-Disposition: inline
In-Reply-To: <20170621132530.11937-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 21, 2017 at 02:25:30PM +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> The return value ret is unitialized and garbage is being returned
> for the three different error conditions when setting up the PCIe
> BARs. Fix this by initializing ret to  -ENOMEM to indicate that
> the BARs failed to be setup correctly.
> 
> Detected by CoverityScan, CID#1437563 ("Unitialized scalar variable")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  drivers/net/wireless/quantenna/qtnfmac/pearl/pcie.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/quantenna/qtnfmac/pearl/pcie.c b/drivers/net/wireless/quantenna/qtnfmac/pearl/pcie.c
> index f93b27f3a236..7fc4f0d6a9ad 100644
> --- a/drivers/net/wireless/quantenna/qtnfmac/pearl/pcie.c
> +++ b/drivers/net/wireless/quantenna/qtnfmac/pearl/pcie.c
> @@ -247,7 +247,7 @@ static void qtnf_pcie_free_shm_ipc(struct qtnf_pcie_bus_priv *priv)
>  
>  static int qtnf_pcie_init_memory(struct qtnf_pcie_bus_priv *priv)
>  {
> -	int ret;
> +	int ret = -ENOMEM;
>  
>  	priv->sysctl_bar = qtnf_map_bar(priv, QTN_SYSCTL_BAR);
>  	if (IS_ERR_OR_NULL(priv->sysctl_bar)) {

Not related to your patch but qtnf_map_bar() should be changed not to
return NULL.  When functions return both NULL and error pointers the
NULL is supposed to be a special type of success return.  Here it is
just a fail return where we forgot to set the error code to
ERR_PTR(-ENOMEM).

regards,
dan carpenter
