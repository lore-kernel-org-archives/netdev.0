From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH] vxge: use max() instead of VXGE_HW_SET_LEVEL
Date: Thu, 23 Apr 2009 23:05:47 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7705313EDF@nekter>
References: <1240538001-11386-1-git-send-email-a.beregalov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Alexander Beregalov" <a.beregalov@gmail.com>,
	<netdev@vger.kernel.org>, "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:8427 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753100AbZDXDFt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 23:05:49 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1240538001-11386-1-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks! Changes look good.

Ram
> -----Original Message-----
> From: Alexander Beregalov [mailto:a.beregalov@gmail.com]
> Sent: Thursday, April 23, 2009 6:53 PM
> To: Ramkrishna Vepa; netdev@vger.kernel.org
> Cc: Alexander Beregalov
> Subject: [PATCH] vxge: use max() instead of VXGE_HW_SET_LEVEL
> 
> 
> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
> ---
>  drivers/net/vxge/vxge-traffic.c |   55
++++++++++++++++------------------
> ----
>  drivers/net/vxge/vxge-traffic.h |    2 -
>  2 files changed, 23 insertions(+), 34 deletions(-)
> 
> diff --git a/drivers/net/vxge/vxge-traffic.c b/drivers/net/vxge/vxge-
> traffic.c
> index 506625b..cf4ebb5 100644
> --- a/drivers/net/vxge/vxge-traffic.c
> +++ b/drivers/net/vxge/vxge-traffic.c
> @@ -505,7 +505,7 @@ enum vxge_hw_status
vxge_hw_device_begin_irq(struct
> __vxge_hw_device *hldev,
>  			ret = __vxge_hw_vpath_alarm_process(
>  				&hldev->virtual_paths[i], skip_alarms);
> 
> -			error_level = VXGE_HW_SET_LEVEL(ret,
error_level);
> +			error_level = max(ret, error_level);
> 
>  			if (unlikely((ret == VXGE_HW_ERR_CRITICAL) ||
>  				(ret == VXGE_HW_ERR_SLOT_FREEZE)))
> @@ -1921,7 +1921,7 @@ enum vxge_hw_status
__vxge_hw_vpath_alarm_process(
>  	struct vxge_hw_vpath_reg __iomem *vp_reg;
> 
>  	if (vpath == NULL) {
> -		alarm_event = VXGE_HW_SET_LEVEL(VXGE_HW_EVENT_UNKNOWN,
> +		alarm_event = max(VXGE_HW_EVENT_UNKNOWN,
>  			alarm_event);
>  		goto out2;
>  	}
> @@ -1931,7 +1931,7 @@ enum vxge_hw_status
__vxge_hw_vpath_alarm_process(
>  	alarm_status = readq(&vp_reg->vpath_general_int_status);
> 
>  	if (alarm_status == VXGE_HW_ALL_FOXES) {
> -		alarm_event =
VXGE_HW_SET_LEVEL(VXGE_HW_EVENT_SLOT_FREEZE,
> +		alarm_event = max(VXGE_HW_EVENT_SLOT_FREEZE,
>  			alarm_event);
>  		goto out;
>  	}
> @@ -1945,7 +1945,7 @@ enum vxge_hw_status
__vxge_hw_vpath_alarm_process(
>  		VXGE_HW_VPATH_GENERAL_INT_STATUS_XMAC_INT)) {
>  		sw_stats->error_stats.unknown_alarms++;
> 
> -		alarm_event = VXGE_HW_SET_LEVEL(VXGE_HW_EVENT_UNKNOWN,
> +		alarm_event = max(VXGE_HW_EVENT_UNKNOWN,
>  			alarm_event);
>  		goto out;
>  	}
> @@ -1975,8 +1975,8 @@ enum vxge_hw_status
__vxge_hw_vpath_alarm_process(
>  					&vp_reg->asic_ntwk_vp_err_mask);
> 
>
__vxge_hw_device_handle_link_down_ind(hldev);
> -				alarm_event = VXGE_HW_SET_LEVEL(
> -					VXGE_HW_EVENT_LINK_DOWN,
alarm_event);
> +				alarm_event =
max(VXGE_HW_EVENT_LINK_DOWN,
> +					alarm_event);
>  			}
> 
>  			if (((val64 &
> @@ -1996,15 +1996,15 @@ enum vxge_hw_status
__vxge_hw_vpath_alarm_process(
>  					&vp_reg->asic_ntwk_vp_err_mask);
> 
>
__vxge_hw_device_handle_link_up_ind(hldev);
> -				alarm_event = VXGE_HW_SET_LEVEL(
> -					VXGE_HW_EVENT_LINK_UP,
alarm_event);
> +				alarm_event = max(VXGE_HW_EVENT_LINK_UP,
> +					alarm_event);
>  			}
> 
>  			writeq(VXGE_HW_INTR_MASK_ALL,
>  				&vp_reg->asic_ntwk_vp_err_reg);
> 
> -			alarm_event = VXGE_HW_SET_LEVEL(
> -				VXGE_HW_EVENT_ALARM_CLEARED,
alarm_event);
> +			alarm_event = max(VXGE_HW_EVENT_ALARM_CLEARED,
> +				alarm_event);
> 
>  			if (skip_alarms)
>  				return VXGE_HW_OK;
> @@ -2026,8 +2026,8 @@ enum vxge_hw_status
__vxge_hw_vpath_alarm_process(
>  				~mask64) {
>  				sw_stats->error_stats.ini_serr_det++;
> 
> -				alarm_event = VXGE_HW_SET_LEVEL(
> -					VXGE_HW_EVENT_SERR,
alarm_event);
> +				alarm_event = max(VXGE_HW_EVENT_SERR,
> +					alarm_event);
>  			}
> 
>  			if ((val64 &
> @@ -2035,8 +2035,8 @@ enum vxge_hw_status
__vxge_hw_vpath_alarm_process(
>  				~mask64) {
>
sw_stats->error_stats.dblgen_fifo0_overflow++;
> 
> -				alarm_event = VXGE_HW_SET_LEVEL(
> -					VXGE_HW_EVENT_FIFO_ERR,
alarm_event);
> +				alarm_event =
max(VXGE_HW_EVENT_FIFO_ERR,
> +					alarm_event);
>  			}
> 
>  			if ((val64 &
> @@ -2057,8 +2057,7 @@ enum vxge_hw_status
__vxge_hw_vpath_alarm_process(
>  			if (!skip_alarms) {
>  				writeq(VXGE_HW_INTR_MASK_ALL,
>  					&vp_reg->general_errors_reg);
> -				alarm_event = VXGE_HW_SET_LEVEL(
> -					VXGE_HW_EVENT_ALARM_CLEARED,
> +				alarm_event =
max(VXGE_HW_EVENT_ALARM_CLEARED,
>  					alarm_event);
>  			}
>  		}
> @@ -2074,8 +2073,7 @@ enum vxge_hw_status
__vxge_hw_vpath_alarm_process(
>  				~mask64) {
>
sw_stats->error_stats.kdfcctl_fifo0_overwrite++;
> 
> -				alarm_event = VXGE_HW_SET_LEVEL(
> -					VXGE_HW_EVENT_FIFO_ERR,
> +				alarm_event =
max(VXGE_HW_EVENT_FIFO_ERR,
>  					alarm_event);
>  			}
> 
> @@ -2084,8 +2082,7 @@ enum vxge_hw_status
__vxge_hw_vpath_alarm_process(
>  				~mask64) {
>
sw_stats->error_stats.kdfcctl_fifo0_poison++;
> 
> -				alarm_event = VXGE_HW_SET_LEVEL(
> -					VXGE_HW_EVENT_FIFO_ERR,
> +				alarm_event =
max(VXGE_HW_EVENT_FIFO_ERR,
>  					alarm_event);
>  			}
> 
> @@ -2094,16 +2091,14 @@ enum vxge_hw_status
__vxge_hw_vpath_alarm_process(
>  				~mask64) {
>
sw_stats->error_stats.kdfcctl_fifo0_dma_error++;
> 
> -				alarm_event = VXGE_HW_SET_LEVEL(
> -					VXGE_HW_EVENT_FIFO_ERR,
> +				alarm_event =
max(VXGE_HW_EVENT_FIFO_ERR,
>  					alarm_event);
>  			}
> 
>  			if (!skip_alarms) {
>  				writeq(VXGE_HW_INTR_MASK_ALL,
>  					&vp_reg->kdfcctl_errors_reg);
> -				alarm_event = VXGE_HW_SET_LEVEL(
> -					VXGE_HW_EVENT_ALARM_CLEARED,
> +				alarm_event =
max(VXGE_HW_EVENT_ALARM_CLEARED,
>  					alarm_event);
>  			}
>  		}
> @@ -2127,8 +2122,7 @@ enum vxge_hw_status
__vxge_hw_vpath_alarm_process(
>  				~mask64) {
>
sw_stats->error_stats.prc_rxdcm_sc_err++;
> 
> -				alarm_event = VXGE_HW_SET_LEVEL(
> -					VXGE_HW_EVENT_VPATH_ERR,
> +				alarm_event =
max(VXGE_HW_EVENT_VPATH_ERR,
>  					alarm_event);
>  			}
> 
> @@ -2136,8 +2130,7 @@ enum vxge_hw_status
__vxge_hw_vpath_alarm_process(
>  				& ~mask64) {
>
sw_stats->error_stats.prc_rxdcm_sc_abort++;
> 
> -				alarm_event = VXGE_HW_SET_LEVEL(
> -						VXGE_HW_EVENT_VPATH_ERR,
> +				alarm_event =
max(VXGE_HW_EVENT_VPATH_ERR,
>  						alarm_event);
>  			}
> 
> @@ -2145,16 +2138,14 @@ enum vxge_hw_status
__vxge_hw_vpath_alarm_process(
>  				 & ~mask64) {
>
sw_stats->error_stats.prc_quanta_size_err++;
> 
> -				alarm_event = VXGE_HW_SET_LEVEL(
> -					VXGE_HW_EVENT_VPATH_ERR,
> +				alarm_event =
max(VXGE_HW_EVENT_VPATH_ERR,
>  					alarm_event);
>  			}
> 
>  			if (!skip_alarms) {
>  				writeq(VXGE_HW_INTR_MASK_ALL,
>  					&vp_reg->prc_alarm_reg);
> -				alarm_event = VXGE_HW_SET_LEVEL(
> -
VXGE_HW_EVENT_ALARM_CLEARED,
> +				alarm_event =
max(VXGE_HW_EVENT_ALARM_CLEARED,
>  						alarm_event);
>  			}
>  		}
> diff --git a/drivers/net/vxge/vxge-traffic.h b/drivers/net/vxge/vxge-
> traffic.h
> index 7567a11..d03f3d3 100644
> --- a/drivers/net/vxge/vxge-traffic.h
> +++ b/drivers/net/vxge/vxge-traffic.h
> @@ -110,8 +110,6 @@ enum vxge_hw_event {
>  	VXGE_HW_EVENT_SLOT_FREEZE	= VXGE_HW_EVENT_BASE + 14,
>  };
> 
> -#define VXGE_HW_SET_LEVEL(a, b) (((a) > (b)) ? (a) : (b))
> -
>  /*
>   * struct vxge_hw_mempool_dma - Represents DMA objects passed to the
>  	caller.
> --
> 1.6.2.3

