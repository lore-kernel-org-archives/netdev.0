From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: e1000e: Fix build with CONFIG_PM disabled.
Date: Wed, 17 Mar 2010 11:57:59 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FE4909419@rrsmsx501.amr.corp.intel.com>
References: <20100316.234100.133957798.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>, "rjw@sisk.pl" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:45377 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754917Ab0CQR6D convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 13:58:03 -0400
In-Reply-To: <20100316.234100.133957798.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> I had to add the following patch to fix the build after
> your changes.
> 
> Thanks.
> 
> e1000e: Fix build with CONFIG_PM disabled.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  drivers/net/e1000e/netdev.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
> index 79b33c5..b96532a 100644
> --- a/drivers/net/e1000e/netdev.c
> +++ b/drivers/net/e1000e/netdev.c
> @@ -5475,6 +5475,7 @@ static DEFINE_PCI_DEVICE_TABLE(e1000_pci_tbl) =
>  { };
>  MODULE_DEVICE_TABLE(pci, e1000_pci_tbl);
> 
> +#ifdef CONFIG_PM
>  static const struct dev_pm_ops e1000_pm_ops = {
>  	.suspend  = e1000_suspend,
>  	.resume   = e1000_resume,
> @@ -5486,6 +5487,7 @@ static const struct dev_pm_ops e1000_pm_ops = {
>  	.runtime_resume = e1000_runtime_resume,
>  	.runtime_idle = e1000_idle,
>  };
> +#endif
> 
>  /* PCI Device API Driver */
>  static struct pci_driver e1000_driver = {
> --
> 1.6.6.1

But then the driver build fails again when CONFIG_PM_RUNTIME is not set.

drivers/net/e1000e/netdev.c: In function `e1000_runtime_resume`:
drivers/net/e1000e/netdev.c:4807: error: `struct dev_pm_info` has no member named `runtime_auto`

Thanks,
Emil