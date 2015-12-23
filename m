From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH V1 15/16] i40iw: add entry in rdma_netlink
Date: Wed, 23 Dec 2015 18:50:15 +0200
Message-ID: <567AD0C7.3010309@mellanox.com>
References: <1450739596-23276-1-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-2-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-3-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-4-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-5-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-6-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-7-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-8-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-9-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-10-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-11-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-12-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-13-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-14-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-15-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-16-git-send-email-faisal.latif@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<e1000-rdma-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1450739596-23276-16-git-send-email-faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/22/2015 1:13 AM, Faisal Latif wrote:
> Add entry for port mapper services.
>
> Signed-off-by: Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> ---
>   include/uapi/rdma/rdma_netlink.h | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/include/uapi/rdma/rdma_netlink.h b/include/uapi/rdma/rdma_netlink.h
> index c19a5dc..4fa418d 100644
> --- a/include/uapi/rdma/rdma_netlink.h
> +++ b/include/uapi/rdma/rdma_netlink.h
> @@ -8,6 +8,7 @@ enum {
>   	RDMA_NL_NES,
>   	RDMA_NL_C4IW,
>   	RDMA_NL_LS,	/* RDMA Local Services */
> +	RDMA_NL_I40IW,
>   	RDMA_NL_NUM_CLIENTS
>   };
>   
Do you use this value in down-stream patches of the series? if yes, 
change the order to have this and other IB core changes before the code 
that use that.

Why the iwarp port mapper implementationhas to be repeated in each 
driver? can you join your code in a common place and avoid the duplication?

root@r-dcs58 hw]# git grep RDMA_NL_ nes
nes/nes.c:      [RDMA_NL_IWPM_REG_PID] = {.dump = iwpm_register_pid_cb},
nes/nes.c:      [RDMA_NL_IWPM_ADD_MAPPING] = {.dump = iwpm_add_mapping_cb},
nes/nes.c:      [RDMA_NL_IWPM_QUERY_MAPPING] = {.dump = 
iwpm_add_and_query_mapping_cb},
nes/nes.c:      [RDMA_NL_IWPM_REMOTE_INFO] = {.dump = iwpm_remote_info_cb},
nes/nes.c:      [RDMA_NL_IWPM_HANDLE_ERR] = {.dump = iwpm_mapping_error_cb},
nes/nes.c:      [RDMA_NL_IWPM_MAPINFO] = {.dump = iwpm_mapping_info_cb},
nes/nes.c:      [RDMA_NL_IWPM_MAPINFO_NUM] = {.dump = 
iwpm_ack_mapping_info_cb}
nes/nes.c:      if (ibnl_add_client(RDMA_NL_NES, RDMA_NL_IWPM_NUM_OPS, 
nes_nl_cb_table))
nes/nes.c:      ret = iwpm_init(RDMA_NL_NES);
nes/nes.c:      ibnl_remove_client(RDMA_NL_NES);
nes/nes.c:      ibnl_remove_client(RDMA_NL_NES);
nes/nes.c:      iwpm_exit(RDMA_NL_NES);
nes/nes_cm.c: &mapped_sockaddr, RDMA_NL_NES);
nes/nes_cm.c:   return iwpm_remove_mapping(&local_sockaddr, RDMA_NL_NES);
nes/nes_cm.c:                           &remote_addr, RDMA_NL_NES);
nes/nes_cm.c:           iwpm_err = iwpm_register_pid(&pm_reg_msg, 
RDMA_NL_NES);
nes/nes_cm.c:                   iwpm_err = iwpm_add_mapping(&pm_msg, 
RDMA_NL_NES);
nes/nes_cm.c:   iwpm_err = iwpm_register_pid(&pm_reg_msg, RDMA_NL_NES);
nes/nes_cm.c:           iwpm_err = iwpm_add_and_query_mapping(&pm_msg, 
RDMA_NL_NES);

[root@r-dcs58 hw]# git grep RDMA_NL_ cxgb4/

cxgb4/cm.c: iwpm_remove_mapping(&ep->com.local_addr, RDMA_NL_C4IW);
cxgb4/cm.c: &child_ep->com.remote_addr, RDMA_NL_C4IW);
cxgb4/cm.c:     iwpm_err = iwpm_register_pid(&pm_reg_msg, RDMA_NL_C4IW);
cxgb4/cm.c:             iwpm_err = iwpm_add_and_query_mapping(&pm_msg, 
RDMA_NL_C4IW);
cxgb4/cm.c: &ep->com.mapped_local_addr, RDMA_NL_C4IW)) {
cxgb4/cm.c: iwpm_remove_mapping(&ep->com.local_addr, RDMA_NL_C4IW);
cxgb4/cm.c:     iwpm_err = iwpm_register_pid(&pm_reg_msg, RDMA_NL_C4IW);
cxgb4/cm.c:             iwpm_err = iwpm_add_mapping(&pm_msg, RDMA_NL_C4IW);
cxgb4/cm.c: &ep->com.mapped_local_addr, RDMA_NL_C4IW)) {
cxgb4/device.c: [RDMA_NL_IWPM_REG_PID] = {.dump = iwpm_register_pid_cb},
cxgb4/device.c: [RDMA_NL_IWPM_ADD_MAPPING] = {.dump = iwpm_add_mapping_cb},
cxgb4/device.c: [RDMA_NL_IWPM_QUERY_MAPPING] = {.dump = 
iwpm_add_and_query_mapping_cb},
cxgb4/device.c: [RDMA_NL_IWPM_HANDLE_ERR] = {.dump = iwpm_mapping_error_cb},
cxgb4/device.c: [RDMA_NL_IWPM_REMOTE_INFO] = {.dump = iwpm_remote_info_cb},
cxgb4/device.c: [RDMA_NL_IWPM_MAPINFO] = {.dump = iwpm_mapping_info_cb},
cxgb4/device.c: [RDMA_NL_IWPM_MAPINFO_NUM] = {.dump = 
iwpm_ack_mapping_info_cb}
cxgb4/device.c: if (ibnl_add_client(RDMA_NL_C4IW, RDMA_NL_IWPM_NUM_OPS,
cxgb4/device.c: err = iwpm_init(RDMA_NL_C4IW);
cxgb4/device.c:         ibnl_remove_client(RDMA_NL_C4IW);
cxgb4/device.c: iwpm_exit(RDMA_NL_C4IW);
cxgb4/device.c: ibnl_remove_client(RDMA_NL_C4IW);

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
