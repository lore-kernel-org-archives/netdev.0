From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 03/13] i40e: use register for XL722 control register
 read/write
Date: Wed, 29 Mar 2017 14:16:52 +0300
Message-ID: <bfc958ff-43fb-2bd6-6fdb-67e7dd0418c0@cogentembedded.com>
References: <20170329101215.24513-1-jeffrey.t.kirsher@intel.com>
 <20170329101215.24513-4-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul M Stillwell Jr <paul.m.stillwell.jr@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:35114 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755979AbdC2LQ4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 07:16:56 -0400
Received: by mail-lf0-f43.google.com with SMTP id j90so5976893lfk.2
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 04:16:55 -0700 (PDT)
In-Reply-To: <20170329101215.24513-4-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 3/29/2017 1:12 PM, Jeff Kirsher wrote:

> From: Paul M Stillwell Jr <paul.m.stillwell.jr@intel.com>
>
> The XL722 doesn't support the AQ command to read/write the control
> register so enable it to bypass the check and use the direct read/write
> method.
>
> Change-ID: Iefecc737b57207485c90845af5989d5af518bf16
> Signed-off-by: Paul M Stillwell Jr <paul.m.stillwell.jr@intel.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_common.c   | 8 ++++++--
>  drivers/net/ethernet/intel/i40evf/i40e_common.c | 8 ++++++--
>  2 files changed, 12 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
> index 95946f41002b..f9db95aa3a20 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_common.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
> @@ -4963,7 +4963,9 @@ u32 i40e_read_rx_ctl(struct i40e_hw *hw, u32 reg_addr)
>  	int retry = 5;
>  	u32 val = 0;
>
> -	use_register = (hw->aq.api_maj_ver == 1) && (hw->aq.api_min_ver < 5);
> +	use_register = (((hw->aq.api_maj_ver == 1) &&
> +			(hw->aq.api_min_ver < 5)) ||
> +			(hw->mac.type == I40E_MAC_X722));

    () around the right operand of the assignment not really needed. Well, 
neither around || and &&...

>  	if (!use_register) {
>  do_retry:
>  		status = i40e_aq_rx_ctl_read_register(hw, reg_addr, &val, NULL);
> @@ -5022,7 +5024,9 @@ void i40e_write_rx_ctl(struct i40e_hw *hw, u32 reg_addr, u32 reg_val)
>  	bool use_register;
>  	int retry = 5;
>
> -	use_register = (hw->aq.api_maj_ver == 1) && (hw->aq.api_min_ver < 5);
> +	use_register = (((hw->aq.api_maj_ver == 1) &&
> +			(hw->aq.api_min_ver < 5)) ||
> +			(hw->mac.type == I40E_MAC_X722));

    Same here...

>  	if (!use_register) {
>  do_retry:
>  		status = i40e_aq_rx_ctl_write_register(hw, reg_addr,
> diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
> index 89dfdbca13db..626fbf1ead4d 100644
> --- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
> +++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
> @@ -958,7 +958,9 @@ u32 i40evf_read_rx_ctl(struct i40e_hw *hw, u32 reg_addr)
>  	int retry = 5;
>  	u32 val = 0;
>
> -	use_register = (hw->aq.api_maj_ver == 1) && (hw->aq.api_min_ver < 5);
> +	use_register = (((hw->aq.api_maj_ver == 1) &&
> +			(hw->aq.api_min_ver < 5)) ||
> +			(hw->mac.type == I40E_MAC_X722));

    And here...

>  	if (!use_register) {
>  do_retry:
>  		status = i40evf_aq_rx_ctl_read_register(hw, reg_addr,
> @@ -1019,7 +1021,9 @@ void i40evf_write_rx_ctl(struct i40e_hw *hw, u32 reg_addr, u32 reg_val)
>  	bool use_register;
>  	int retry = 5;
>
> -	use_register = (hw->aq.api_maj_ver == 1) && (hw->aq.api_min_ver < 5);
> +	use_register = (((hw->aq.api_maj_ver == 1) &&
> +			(hw->aq.api_min_ver < 5)) ||
> +			(hw->mac.type == I40E_MAC_X722));

    And here...

>  	if (!use_register) {
>  do_retry:
>  		status = i40evf_aq_rx_ctl_write_register(hw, reg_addr,

MBR, Sergei
