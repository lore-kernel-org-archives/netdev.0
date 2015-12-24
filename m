From: Faisal Latif <faisal.latif@intel.com>
Subject: Re: [PATCH V1 15/16] i40iw: add entry in rdma_netlink
Date: Thu, 24 Dec 2015 01:05:51 -0600
Message-ID: <20151224070551.GA13684@flatif-MOBL1>
References: <1450739596-23276-8-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-9-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-10-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-11-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-12-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-13-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-14-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-15-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-16-git-send-email-faisal.latif@intel.com>
 <567AD0C7.3010309@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dledford@redhat.com" <dledford@redhat.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"e1000-rdma@lists.sourceforge.net" <e1000-rdma@lists.sourceforge.net>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:45078 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754407AbbLXHFy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Dec 2015 02:05:54 -0500
Content-Disposition: inline
In-Reply-To: <567AD0C7.3010309@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 23, 2015 at 08:50:15AM -0800, Or Gerlitz wrote:
> On 12/22/2015 1:13 AM, Faisal Latif wrote:
> > Add entry for port mapper services.
> >
> > Signed-off-by: Faisal Latif <faisal.latif@intel.com>
> > ---
> >   include/uapi/rdma/rdma_netlink.h | 1 +
> >   1 file changed, 1 insertion(+)
> >
> > diff --git a/include/uapi/rdma/rdma_netlink.h b/include/uapi/rdma/rdma_netlink.h
> > index c19a5dc..4fa418d 100644
> > --- a/include/uapi/rdma/rdma_netlink.h
> > +++ b/include/uapi/rdma/rdma_netlink.h
> > @@ -8,6 +8,7 @@ enum {
> >   	RDMA_NL_NES,
> >   	RDMA_NL_C4IW,
> >   	RDMA_NL_LS,	/* RDMA Local Services */
> > +	RDMA_NL_I40IW,
> >   	RDMA_NL_NUM_CLIENTS
> >   };
> >   
> Do you use this value in down-stream patches of the series? if yes, 
> change the order to have this and other IB core changes before the code 
> that use that.

Yes, I will move this patch up before it being used.

> 
> Why the iwarp port mapper implementationhas to be repeated in each 
> driver? can you join your code in a common place and avoid the duplication?
> 
> root@r-dcs58 hw]# git grep RDMA_NL_ nes
> nes/nes.c:      [RDMA_NL_IWPM_REG_PID] = {.dump = iwpm_register_pid_cb},
> nes/nes.c:      [RDMA_NL_IWPM_ADD_MAPPING] = {.dump = iwpm_add_mapping_cb},
> nes/nes.c:      [RDMA_NL_IWPM_QUERY_MAPPING] = {.dump = 
> iwpm_add_and_query_mapping_cb},
> nes/nes.c:      [RDMA_NL_IWPM_REMOTE_INFO] = {.dump = iwpm_remote_info_cb},
> nes/nes.c:      [RDMA_NL_IWPM_HANDLE_ERR] = {.dump = iwpm_mapping_error_cb},
> nes/nes.c:      [RDMA_NL_IWPM_MAPINFO] = {.dump = iwpm_mapping_info_cb},
> nes/nes.c:      [RDMA_NL_IWPM_MAPINFO_NUM] = {.dump = 
> iwpm_ack_mapping_info_cb}
> nes/nes.c:      if (ibnl_add_client(RDMA_NL_NES, RDMA_NL_IWPM_NUM_OPS, 
> nes_nl_cb_table))
> nes/nes.c:      ret = iwpm_init(RDMA_NL_NES);
> nes/nes.c:      ibnl_remove_client(RDMA_NL_NES);
> nes/nes.c:      ibnl_remove_client(RDMA_NL_NES);
> nes/nes.c:      iwpm_exit(RDMA_NL_NES);
> nes/nes_cm.c: &mapped_sockaddr, RDMA_NL_NES);
> nes/nes_cm.c:   return iwpm_remove_mapping(&local_sockaddr, RDMA_NL_NES);
> nes/nes_cm.c:                           &remote_addr, RDMA_NL_NES);
> nes/nes_cm.c:           iwpm_err = iwpm_register_pid(&pm_reg_msg, 
> RDMA_NL_NES);
> nes/nes_cm.c:                   iwpm_err = iwpm_add_mapping(&pm_msg, 
> RDMA_NL_NES);
> nes/nes_cm.c:   iwpm_err = iwpm_register_pid(&pm_reg_msg, RDMA_NL_NES);
> nes/nes_cm.c:           iwpm_err = iwpm_add_and_query_mapping(&pm_msg, 
> RDMA_NL_NES);
> 
> [root@r-dcs58 hw]# git grep RDMA_NL_ cxgb4/
> 
> cxgb4/cm.c: iwpm_remove_mapping(&ep->com.local_addr, RDMA_NL_C4IW);
> cxgb4/cm.c: &child_ep->com.remote_addr, RDMA_NL_C4IW);
> cxgb4/cm.c:     iwpm_err = iwpm_register_pid(&pm_reg_msg, RDMA_NL_C4IW);
> cxgb4/cm.c:             iwpm_err = iwpm_add_and_query_mapping(&pm_msg, 
> RDMA_NL_C4IW);
> cxgb4/cm.c: &ep->com.mapped_local_addr, RDMA_NL_C4IW)) {
> cxgb4/cm.c: iwpm_remove_mapping(&ep->com.local_addr, RDMA_NL_C4IW);
> cxgb4/cm.c:     iwpm_err = iwpm_register_pid(&pm_reg_msg, RDMA_NL_C4IW);
> cxgb4/cm.c:             iwpm_err = iwpm_add_mapping(&pm_msg, RDMA_NL_C4IW);
> cxgb4/cm.c: &ep->com.mapped_local_addr, RDMA_NL_C4IW)) {
> cxgb4/device.c: [RDMA_NL_IWPM_REG_PID] = {.dump = iwpm_register_pid_cb},
> cxgb4/device.c: [RDMA_NL_IWPM_ADD_MAPPING] = {.dump = iwpm_add_mapping_cb},
> cxgb4/device.c: [RDMA_NL_IWPM_QUERY_MAPPING] = {.dump = 
> iwpm_add_and_query_mapping_cb},
> cxgb4/device.c: [RDMA_NL_IWPM_HANDLE_ERR] = {.dump = iwpm_mapping_error_cb},
> cxgb4/device.c: [RDMA_NL_IWPM_REMOTE_INFO] = {.dump = iwpm_remote_info_cb},
> cxgb4/device.c: [RDMA_NL_IWPM_MAPINFO] = {.dump = iwpm_mapping_info_cb},
> cxgb4/device.c: [RDMA_NL_IWPM_MAPINFO_NUM] = {.dump = 
> iwpm_ack_mapping_info_cb}
> cxgb4/device.c: if (ibnl_add_client(RDMA_NL_C4IW, RDMA_NL_IWPM_NUM_OPS,
> cxgb4/device.c: err = iwpm_init(RDMA_NL_C4IW);
> cxgb4/device.c:         ibnl_remove_client(RDMA_NL_C4IW);
> cxgb4/device.c: iwpm_exit(RDMA_NL_C4IW);
> cxgb4/device.c: ibnl_remove_client(RDMA_NL_C4IW);
> 

i40iw iwarp driver registers with port mapper and uses its services. Beside that it is not
the scope of the patch series.

Thanks
Faisal
