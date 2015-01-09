From: "Ronciak, John" <john.ronciak@intel.com>
Subject: RE: [PATCH] i40e: don't enable and init FCOE by default when do PF
 reset
Date: Fri, 9 Jan 2015 16:41:51 +0000
Message-ID: <D38E8E86660E514AB505863C19C9287C741097AF@ORSMSX102.amr.corp.intel.com>
References: <1420821466-5747-1-git-send-email-ethan.zhao@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Linux NICS <Linux-nics@isotope.jf.intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"ethan.kernel@gmail.com" <ethan.kernel@gmail.com>,
	"brian.maly@oracle.com" <brian.maly@oracle.com>
To: Ethan Zhao <ethan.zhao@oracle.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"Dev, Vasu" <vasu.dev@intel.com>,
	"Parikh, Neerav" <neerav.parikh@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:9768 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753066AbbAIQlw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 11:41:52 -0500
In-Reply-To: <1420821466-5747-1-git-send-email-ethan.zhao@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding Vasu and Neerav

Cheers,
John

> -----Original Message-----
> From: Ethan Zhao [mailto:ethan.zhao@oracle.com]
> Sent: Friday, January 9, 2015 8:38 AM
> To: Kirsher, Jeffrey T; Brandeburg, Jesse; Allan, Bruce W; Wyborny, Carolyn;
> Skidmore, Donald C; Rose, Gregory V; Vick, Matthew; Ronciak, John;
> Williams, Mitch A
> Cc: Linux NICS; e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org;
> linux-kernel@vger.kernel.org; ethan.kernel@gmail.com;
> brian.maly@oracle.com; Ethan Zhao
> Subject: [PATCH] i40e: don't enable and init FCOE by default when do PF
> reset
> 
> While do PF reset with function i40e_reset_and_rebuild(), it will call
> i40e_init_pf_fcoe() by default if FCOE is defined, thus if the PF is resetted,
> FCOE will be enabled whatever it was - enabled or not.
> 
> Such bug might be hit when PF resumes from suspend, run diagnostic test
> with ethtool, setup VLAN etc.
> 
> Passed building with v3.19-rc3.
> 
> Signed-off-by: Ethan Zhao <ethan.zhao@oracle.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_main.c | 9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c
> b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index a5f2660..a2572cc 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -6180,9 +6180,12 @@ static void i40e_reset_and_rebuild(struct i40e_pf
> *pf, bool reinit)
>  	}
>  #endif /* CONFIG_I40E_DCB */
>  #ifdef I40E_FCOE
> -	ret = i40e_init_pf_fcoe(pf);
> -	if (ret)
> -		dev_info(&pf->pdev->dev, "init_pf_fcoe failed: %d\n", ret);
> +	if (pf->flags & I40E_FLAG_FCOE_ENABLED) {
> +		ret = i40e_init_pf_fcoe(pf);
> +		if (ret)
> +			dev_info(&pf->pdev->dev,
> +				 "init_pf_fcoe failed: %d\n", ret);
> +	}
> 
>  #endif
>  	/* do basic switch setup */
> --
> 1.8.3.1
