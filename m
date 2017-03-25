From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 05/11] i40e: fix for queue timing delays
Date: Sat, 25 Mar 2017 13:31:42 +0300
Message-ID: <6f47c4cb-c345-99f9-aabd-eec274ecfbcf@cogentembedded.com>
References: <20170325081305.31835-1-jeffrey.t.kirsher@intel.com>
 <20170325081305.31835-6-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:34018 "EHLO
        mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751054AbdCYKbp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 25 Mar 2017 06:31:45 -0400
Received: by mail-lf0-f42.google.com with SMTP id z15so4059406lfd.1
        for <netdev@vger.kernel.org>; Sat, 25 Mar 2017 03:31:43 -0700 (PDT)
In-Reply-To: <20170325081305.31835-6-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/25/2017 11:12 AM, Jeff Kirsher wrote:

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

    Please add a space before */.

> +	mdelay(50);

    Ugh...

>  	return ret;
>  }

MBR, Sergei
