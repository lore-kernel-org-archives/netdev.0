From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [PATCH v5] i40e: Look up MAC address in Open Firmware or IDPROM
Date: Wed, 4 Nov 2015 23:01:37 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E418AFAEA32@fmsmsx115.amr.corp.intel.com>
References: <20151104193956.GD14575@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"andy.shevchenko@gmail.com" <andy.shevchenko@gmail.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151104193956.GD14575@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Sowmini Varadhan [mailto:sowmini.varadhan@oracle.com]
> Sent: Wednesday, November 04, 2015 11:40 AM
> 
> 
> This is the i40e equivalent of commit c762dff24c06 ("ixgbe: Look up MAC
> address in Open Firmware or IDPROM").
> 
> As with that fix, attempt to look up the MAC address in Open Firmware
> on systems that support it, and use IDPROM on SPARC if no OF address
> is found.
> 
> In the case of the i40e there is an assumption that the default mac
> address has already been set up as the primary mac filter on probe,
> so if this filter is obtained from the Open Firmware or IDPROM, an
> explicit write is needed via i40e_aq_mac_address_write() and
> i40e_aq_add_macvlan() invocation.
> 
> Reviewed-by: Martin K. Petersen <martin.petersen@oracle.com>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
> v2, v3: Andy Shevchenko comments
> v4: Shannon Nelson review: explicitly set up mac filters before
> register_netdev
> v5: Shannon Nelson code style comments
> 
>  drivers/net/ethernet/intel/i40e/i40e_main.c |   84
> ++++++++++++++++++++++++++-
>  1 files changed, 83 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c
> b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index b825f97..a3883cf 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -24,6 +24,15 @@
>   *
> 
> **************************************************************************
> ****/
> 
> +#include <linux/etherdevice.h>
> +#include <linux/of_net.h>
> +#include <linux/pci.h>
> +
> +#ifdef CONFIG_SPARC
> +#include <asm/idprom.h>
> +#include <asm/prom.h>
> +#endif
> +
>  /* Local includes */
>  #include "i40e.h"
>  #include "i40e_diag.h"
> @@ -9213,6 +9222,44 @@ static struct i40e_vsi
> *i40e_vsi_reinit_setup(struct i40e_vsi *vsi)
>  }
> 
>  /**
> + * i40e_macaddr_init - explicitly write the mac address filters. This
> + * is needed when the macaddr has been obtained by other means than
> + * the default, e.g., from Open Firmware or IDPROM.

Note that this should be a simple single line, function name and short summary; anything more detailed goes into a description after the variables.


[...]

> 
>  /**
> + * i40e_get_platform_mac_addr - get mac address from Open Firmware
> + * or IDPROM if supported by the platform

Again, single line.

Thanks for your work on this, Sowmini.  If you can do a quick repost with these little function header comment bits tweaked, I'm willing to ACK this patch and I think we'll be ready for Jeff to include it into his tree.

sln
