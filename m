From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [net-next-2.6 PATCH] enic: fix compile when CONFIG_PCI_IOV is
 not	enabled
Date: Fri, 20 Jan 2012 14:49:41 -0800
Message-ID: <4F19EF85.4040807@xenotime.net>
References: <20120120082536.18521.86316.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Roopa Prabhu <roprabhu@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oproxy9.bluehost.com ([69.89.24.6]:55561 "HELO
	oproxy9.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751795Ab2ATVvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2012 16:51:14 -0500
In-Reply-To: <20120120082536.18521.86316.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/20/2012 12:25 AM, Roopa Prabhu wrote:
> From: Roopa Prabhu <roprabhu@cisco.com>
> 
> reverting back change that access enic->num_vfs outside
> CONFIG_PCI_IOV
> 
> Reported-by: Randy Dunlap <rdunlap@xenotime.net>
> Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>

Acked-by: Randy Dunlap <rdunlap@xenotime.net>

Thanks.

> ---
>  drivers/net/ethernet/cisco/enic/enic_main.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> 
> diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
> index 045c468..ab3f67f 100644
> --- a/drivers/net/ethernet/cisco/enic/enic_main.c
> +++ b/drivers/net/ethernet/cisco/enic/enic_main.c
> @@ -2273,7 +2273,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
>  #ifdef CONFIG_PCI_IOV
>  	int pos = 0;
>  #endif
> -	int num_pps;
> +	int num_pps = 1;
>  
>  	/* Allocate net device structure and initialize.  Private
>  	 * instance data is initialized to zero.
> @@ -2380,11 +2380,11 @@ static int __devinit enic_probe(struct pci_dev *pdev,
>  				goto err_out_vnic_unregister;
>  			}
>  			enic->priv_flags |= ENIC_SRIOV_ENABLED;
> +			num_pps = enic->num_vfs;
>  		}
>  	}
>  #endif
>  
> -	num_pps = enic->num_vfs ? enic->num_vfs : 1;
>  	/* Allocate structure for port profiles */
>  	enic->pp = kcalloc(num_pps, sizeof(*enic->pp), GFP_KERNEL);
>  	if (!enic->pp) {
> 
> --


-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
