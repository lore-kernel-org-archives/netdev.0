From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [PATCH] i40e/i40evf: actually use u32 for feature flags
Date: Wed, 11 Oct 2017 22:21:06 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5882AC476B@ORSMSX115.amr.corp.intel.com>
References: <20171011140316.3802721-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        "Williams, Mitch A" <mitch.a.williams@intel.com>,
        "Sadowski, Filip" <filip.sadowski@intel.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171011140316.3802721-1-arnd@arndb.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Arnd Bergmann [mailto:arnd@arndb.de]
> Sent: Wednesday, October 11, 2017 7:03 AM
> To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>
> Cc: Arnd Bergmann <arnd@arndb.de>; Keller, Jacob E
> <jacob.e.keller@intel.com>; Duyck, Alexander H
> <alexander.h.duyck@intel.com>; Williams, Mitch A
> <mitch.a.williams@intel.com>; Sadowski, Filip <filip.sadowski@intel.com>; intel-
> wired-lan@lists.osuosl.org; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org
> Subject: [PATCH] i40e/i40evf: actually use u32 for feature flags
> 
> A previous cleanup intended to change the flags variable to 32
> bit instead of 64, but accidentally left out the important
> part of that change, leading to a build error:
> 
> drivers/net/ethernet/intel/i40e/i40e_ethtool.o: In function `i40e_set_priv_flags':
> i40e_ethtool.c:(.text+0x1a94): undefined reference to `wrong_size_cmpxchg'
> 
> This adds the missing modification.
> 

Hah good eyes. I'm guessing this got messed up in a patch re-ordering.

Acked-by: Jacob Keller <jacob.e.keller@intel.com>

> Fixes: b74f571f59a8 ("i40e/i40evf: organize and re-number feature flags")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/net/ethernet/intel/i40e/i40e.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/intel/i40e/i40e.h
> b/drivers/net/ethernet/intel/i40e/i40e.h
> index 18c453a3e728..7baf6d8a84dd 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e.h
> +++ b/drivers/net/ethernet/intel/i40e/i40e.h
> @@ -424,7 +424,7 @@ struct i40e_pf {
>  #define I40E_HW_PORT_ID_VALID			BIT(17)
>  #define I40E_HW_RESTART_AUTONEG			BIT(18)
> 
> -	u64 flags;
> +	u32 flags;
>  #define I40E_FLAG_RX_CSUM_ENABLED		BIT(0)
>  #define I40E_FLAG_MSI_ENABLED			BIT(1)
>  #define I40E_FLAG_MSIX_ENABLED			BIT(2)
> --
> 2.9.0
