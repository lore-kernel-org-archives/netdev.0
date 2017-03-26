From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 05/11] i40e: fix for queue timing delays
Date: Sat, 25 Mar 2017 20:00:45 -0700 (PDT)
Message-ID: <20170325.200045.766752589165691684.davem@davemloft.net>
References: <20170325081305.31835-1-jeffrey.t.kirsher@intel.com>
        <20170325081305.31835-6-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: carolyn.wyborny@intel.com, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59900 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751271AbdCZDA4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 25 Mar 2017 23:00:56 -0400
In-Reply-To: <20170325081305.31835-6-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 25 Mar 2017 01:12:59 -0700

> From: Carolyn Wyborny <carolyn.wyborny@intel.com>
> 
> This patch adds a delay to Rx queue disables to accommodate HW needs.
> 
> Change-ID: I2864ca667ce5dcc2cc44f8718113b719742a46a1
> Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_main.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index 5da990909a88..1435033faefe 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -4181,6 +4181,8 @@ static int i40e_vsi_control_rx(struct i40e_vsi *vsi, bool enable)
>  		}
>  	}
>  
> +	/* HW needs up to 50ms to finish RX queue disable*/
> +	mdelay(50);

You just polled a register which indicates that the request is finished.
Needing futher time for the operation to complete doesn't make any
sense.

If this is really needed, you need to explain in the commit message, in
detail, what is really the problem here.

THanks.
