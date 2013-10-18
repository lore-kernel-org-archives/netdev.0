From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next  03/14] i40e: assign correct vector to VF
Date: Fri, 18 Oct 2013 18:08:30 +0400
Message-ID: <526140DE.8000009@cogentembedded.com>
References: <1382102598-11343-1-git-send-email-jeffrey.t.kirsher@intel.com> <1382102598-11343-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, a@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:34385 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756131Ab3JROJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 10:09:31 -0400
Received: by mail-lb0-f179.google.com with SMTP id p9so3153559lbv.38
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 07:09:30 -0700 (PDT)
In-Reply-To: <1382102598-11343-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 18-10-2013 17:23, Jeff Kirsher wrote:

> From: Mitch Williams <mitch.a.williams@intel.com>

> Correct math error when assigning MSI-X vectors to VFs. The vectors-per-vf
> value reported by the hardware already conveniently reports one less than the
> actual value.

> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Sibai Li <sibai.li@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
> index 8967e58..202139f 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
> @@ -251,7 +251,7 @@ static void i40e_config_irq_link_list(struct i40e_vf *vf, u16 vsi_idx,
>   		reg_idx = I40E_VPINT_LNKLST0(vf->vf_id);
>   	else
>   		reg_idx = I40E_VPINT_LNKLSTN(
> -			    ((pf->hw.func_caps.num_msix_vectors_vf - 1)
> +			    ((pf->hw.func_caps.num_msix_vectors_vf)

    Why keep the parens if you've removed -1?

WBR, Sergei
