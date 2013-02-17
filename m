From: walter harms <wharms@bfs.de>
Subject: Re: [PATCH] ethernet: neterion: vxge: vxge-traffic.c: fix for a potential
 NULL pointer dereference
Date: Sun, 17 Feb 2013 15:49:28 +0100
Message-ID: <5120EDF8.7010503@bfs.de>
References: <1361037394-14731-1-git-send-email-gmate.amit@gmail.com>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: jdmason@kudzu.us, davem@davemloft.net, joe@perches.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Kumar Amit Mehta <gmate.amit@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1361037394-14731-1-git-send-email-gmate.amit@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Am 16.02.2013 18:56, schrieb Kumar Amit Mehta:
> fix for a potential NULL pointer dereference and removal of a redundant
> assignment operation. Found using smatch.
> 
> Signed-off-by: Kumar Amit Mehta <gmate.amit@gmail.com>
> ---
>  drivers/net/ethernet/neterion/vxge/vxge-traffic.c |    8 ++------
>  1 file changed, 2 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/ethernet/neterion/vxge/vxge-traffic.c b/drivers/net/ethernet/neterion/vxge/vxge-traffic.c
> index 99749bd..adb05a8 100644
> --- a/drivers/net/ethernet/neterion/vxge/vxge-traffic.c
> +++ b/drivers/net/ethernet/neterion/vxge/vxge-traffic.c
> @@ -611,11 +611,8 @@ __vxge_hw_vpath_alarm_process(struct __vxge_hw_virtualpath *vpath,
>  	struct vxge_hw_vpath_stats_sw_info *sw_stats;
>  	struct vxge_hw_vpath_reg __iomem *vp_reg;
>  
> -	if (vpath == NULL) {
> -		alarm_event = VXGE_HW_SET_LEVEL(VXGE_HW_EVENT_UNKNOWN,
> -			alarm_event);
> +	if (vpath == NULL)
>  		goto out2;
> -	}
>  
>  	hldev = vpath->hldev;
>  	vp_reg = vpath->vp_reg;
> @@ -852,13 +849,12 @@ __vxge_hw_vpath_alarm_process(struct __vxge_hw_virtualpath *vpath,
>  	}
>  out:
>  	hldev->stats.sw_dev_err_stats.vpath_alarms++;
> +	__vxge_hw_device_handle_error(hldev, vpath->vp_id, alarm_event);
>  out2:
>  	if ((alarm_event == VXGE_HW_EVENT_ALARM_CLEARED) ||
>  		(alarm_event == VXGE_HW_EVENT_UNKNOWN))
>  		return VXGE_HW_OK;
>  
> -	__vxge_hw_device_handle_error(hldev, vpath->vp_id, alarm_event);
> -
>  	if (alarm_event == VXGE_HW_EVENT_SERR)
>  		return VXGE_HW_ERR_CRITICAL;
>  

the patch looks ok.
it would be nice if someone would rewrite the if (alarm_event == x ) stuff
using switch or more if()'s it is hardly readable this way.

just my 2 cents,
re,
 wh
