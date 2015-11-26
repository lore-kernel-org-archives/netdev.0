From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 12/15] i40evf: fix compiler warning of unused variable
Date: Thu, 26 Nov 2015 17:03:59 +0300
Message-ID: <5657114F.2020009@cogentembedded.com>
References: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1448307376-20063-13-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:33111 "EHLO
	mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016AbbKZOEC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 09:04:02 -0500
Received: by lfaz4 with SMTP id z4so98962937lfa.0
        for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 06:04:00 -0800 (PST)
In-Reply-To: <1448307376-20063-13-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/23/2015 10:36 PM, Jeff Kirsher wrote:

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
>
> Compiler complained of an unused variable, which the driver was just
> using to store the result of a rd32 which is used to clear a register
> unconditionally.  Just drop the unused variable and re-use one.

   I don't see Jesse dropping anything...

> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/i40evf/i40evf_main.c | 7 +++----
>   1 file changed, 3 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
> index d962164..6ad6265 100644
> --- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
> +++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
> @@ -307,10 +307,9 @@ static irqreturn_t i40evf_msix_aq(int irq, void *data)
>   	struct i40e_hw *hw = &adapter->hw;
>   	u32 val;
>
> -	/* handle non-queue interrupts */
> -	rd32(hw, I40E_VFINT_ICR01);
> -	rd32(hw, I40E_VFINT_ICR0_ENA1);
> -
> +	/* handle non-queue interrupts, these reads clear the registers */
> +	val = rd32(hw, I40E_VFINT_ICR01);
> +	val = rd32(hw, I40E_VFINT_ICR0_ENA1);

    Why if it's ignored anyway?

>
>   	val = rd32(hw, I40E_VFINT_DYN_CTL01) |
>   	      I40E_VFINT_DYN_CTL01_CLEARPBA_MASK;


MBR, Sergei
