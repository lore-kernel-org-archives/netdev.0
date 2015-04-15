From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 11/14] i40e: handle possible memory allocation failure
Date: Wed, 15 Apr 2015 14:27:56 +0300
Message-ID: <552E4B3C.60002@cogentembedded.com>
References: <1429073511-27664-1-git-send-email-jeffrey.t.kirsher@intel.com> <1429073511-27664-12-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:33066 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753934AbbDOL17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 07:27:59 -0400
Received: by layy10 with SMTP id y10so30171379lay.0
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2015 04:27:58 -0700 (PDT)
In-Reply-To: <1429073511-27664-12-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 4/15/2015 7:51 AM, Jeff Kirsher wrote:

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>

> The init_interrupt_scheme function had a possible failure
> path to allocate memory that was found by smatch.

> This adds the correct handling to the function to abort
> probe if the memory allocation fails.

> Change-ID: I2bf1d826a244209619da4c452d0d58b3eb5e26a3
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Jim Young <james.m.young@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/i40e/i40e_main.c | 14 +++++++++++---
>   1 file changed, 11 insertions(+), 3 deletions(-)

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index 63de3f4..b297294 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
[...]
> @@ -7343,11 +7343,17 @@ static void i40e_init_interrupt_scheme(struct i40e_pf *pf)
>   	/* set up vector assignment tracking */
>   	size = sizeof(struct i40e_lump_tracking) + (sizeof(u16) * vectors);
>   	pf->irq_pile = kzalloc(size, GFP_KERNEL);
> +	if (!pf->irq_pile) {
> +		dev_err(&pf->pdev->dev, "error allocating irq_pile memory\n");

    No need for error message, a call trace will be printed on failed 
allocation anyway.

[...]

WBR, Sergei
