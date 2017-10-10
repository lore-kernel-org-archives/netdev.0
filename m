From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [PATCH] i40e: mark PM functions as __maybe_unused
Date: Tue, 10 Oct 2017 20:11:39 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5882AC2464@ORSMSX115.amr.corp.intel.com>
References: <20171010081847.4090496-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Williams, Mitch A" <mitch.a.williams@intel.com>,
        "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        "Brady, Alan" <alan.brady@intel.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171010081847.4090496-1-arnd@arndb.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Arnd Bergmann [mailto:arnd@arndb.de]
> Sent: Tuesday, October 10, 2017 1:18 AM
> To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>
> Cc: Arnd Bergmann <arnd@arndb.de>; Keller, Jacob E
> <jacob.e.keller@intel.com>; Williams, Mitch A <mitch.a.williams@intel.com>;
> Duyck, Alexander H <alexander.h.duyck@intel.com>; David S. Miller
> <davem@davemloft.net>; Brady, Alan <alan.brady@intel.com>; intel-wired-
> lan@lists.osuosl.org; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: [PATCH] i40e: mark PM functions as __maybe_unused
> 
> A cleanup of the PM code left an incorrect #ifdef in place, leading
> to a harmless build warning:
> 
> drivers/net/ethernet/intel/i40e/i40e_main.c:12223:12: error: 'i40e_resume'
> defined but not used [-Werror=unused-function]
> drivers/net/ethernet/intel/i40e/i40e_main.c:12185:12: error: 'i40e_suspend'
> defined but not used [-Werror=unused-function]
> 
> It's easier to use __maybe_unused attributes here, since you
> can't pick the wrong one.
> 

Sure.

Acked-by: Jacob Keller <jacob.e.keller@intel.com>

> Fixes: 0e5d3da40055 ("i40e: use newer generic PM support instead of legacy PM
> callbacks")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_main.c | 11 ++---------
>  1 file changed, 2 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c
> b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index 60b11fdeca2d..eb091268bc3c 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -8370,7 +8370,6 @@ static int i40e_init_interrupt_scheme(struct i40e_pf
> *pf)
>  	return 0;
>  }
> 
> -#ifdef CONFIG_PM
>  /**
>   * i40e_restore_interrupt_scheme - Restore the interrupt scheme
>   * @pf: private board data structure
> @@ -8419,7 +8418,6 @@ static int i40e_restore_interrupt_scheme(struct i40e_pf
> *pf)
> 
>  	return err;
>  }
> -#endif /* CONFIG_PM */
> 
>  /**
>   * i40e_setup_misc_vector - Setup the misc vector to handle non queue events
> @@ -12177,12 +12175,11 @@ static void i40e_shutdown(struct pci_dev *pdev)
>  	}
>  }
> 
> -#ifdef CONFIG_PM
>  /**
>   * i40e_suspend - PM callback for moving to D3
>   * @dev: generic device information structure
>   **/
> -static int i40e_suspend(struct device *dev)
> +static int __maybe_unused i40e_suspend(struct device *dev)
>  {
>  	struct pci_dev *pdev = to_pci_dev(dev);
>  	struct i40e_pf *pf = pci_get_drvdata(pdev);
> @@ -12220,7 +12217,7 @@ static int i40e_suspend(struct device *dev)
>   * i40e_resume - PM callback for waking up from D3
>   * @dev: generic device information structure
>   **/
> -static int i40e_resume(struct device *dev)
> +static int __maybe_unused i40e_resume(struct device *dev)
>  {
>  	struct pci_dev *pdev = to_pci_dev(dev);
>  	struct i40e_pf *pf = pci_get_drvdata(pdev);
> @@ -12252,8 +12249,6 @@ static int i40e_resume(struct device *dev)
>  	return 0;
>  }
> 
> -#endif /* CONFIG_PM */
> -
>  static const struct pci_error_handlers i40e_err_handler = {
>  	.error_detected = i40e_pci_error_detected,
>  	.slot_reset = i40e_pci_error_slot_reset,
> @@ -12269,11 +12264,9 @@ static struct pci_driver i40e_driver = {
>  	.id_table = i40e_pci_tbl,
>  	.probe    = i40e_probe,
>  	.remove   = i40e_remove,
> -#ifdef CONFIG_PM
>  	.driver   = {
>  		.pm = &i40e_pm_ops,
>  	},
> -#endif /* CONFIG_PM */
>  	.shutdown = i40e_shutdown,
>  	.err_handler = &i40e_err_handler,
>  	.sriov_configure = i40e_pci_sriov_configure,
> --
> 2.9.0
