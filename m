From: Greg <gvrose8192@gmail.com>
Subject: Re: [net 2/2] ixgbevf: ixgbevf_write/read_posted_mbx should use
 IXGBE_ERR_MBX to initialize ret_val
Date: Wed, 29 Jun 2016 09:38:59 -0700
Message-ID: <1467218339.3404.4.camel@gmail.com>
References: <1467217804-137463-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1467217804-137463-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Xin Long <lucien.xin@gmail.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33437 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921AbcF2Qjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 12:39:42 -0400
Received: by mail-pf0-f193.google.com with SMTP id c74so4945304pfb.0
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2016 09:39:01 -0700 (PDT)
In-Reply-To: <1467217804-137463-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-06-29 at 09:30 -0700, Jeff Kirsher wrote:
> From: Xin Long <lucien.xin@gmail.com>
> 
> Now ixgbevf_write/read_posted_mbx use -IXGBE_ERR_MBX as the initiative
> return value, but it's incorrect, cause in ixgbevf_vlan_rx_add_vid(),
> it use err == IXGBE_ERR_MBX, the err returned from mac.ops.set_vfta,
> and in ixgbevf_set_vfta_vf, it return from write/read_posted. so we
> should initialize err with IXGBE_ERR_MBX, instead of -IXGBE_ERR_MBX.

I believe "initiative" should be "initial", "cause" should be "because"
and "it use err" should be "it uses err".  And I won't be a grammar nazi
about all the commas.

- Greg

> 
> With this fix, the other functions that called it also can work well,
> cause they only care about if err is 0 or not.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbevf/mbx.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbevf/mbx.c b/drivers/net/ethernet/intel/ixgbevf/mbx.c
> index 61a80da..2819abc 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/mbx.c
> +++ b/drivers/net/ethernet/intel/ixgbevf/mbx.c
> @@ -85,7 +85,7 @@ static s32 ixgbevf_poll_for_ack(struct ixgbe_hw *hw)
>  static s32 ixgbevf_read_posted_mbx(struct ixgbe_hw *hw, u32 *msg, u16 size)
>  {
>  	struct ixgbe_mbx_info *mbx = &hw->mbx;
> -	s32 ret_val = -IXGBE_ERR_MBX;
> +	s32 ret_val = IXGBE_ERR_MBX;
>  
>  	if (!mbx->ops.read)
>  		goto out;
> @@ -111,7 +111,7 @@ out:
>  static s32 ixgbevf_write_posted_mbx(struct ixgbe_hw *hw, u32 *msg, u16 size)
>  {
>  	struct ixgbe_mbx_info *mbx = &hw->mbx;
> -	s32 ret_val = -IXGBE_ERR_MBX;
> +	s32 ret_val = IXGBE_ERR_MBX;
>  
>  	/* exit if either we can't write or there isn't a defined timeout */
>  	if (!mbx->ops.write || !mbx->timeout)
