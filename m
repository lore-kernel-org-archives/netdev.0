From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v3 00/16] add Intel X722 iWARP driver
Date: Thu, 21 Jan 2016 09:53:51 +0200
Message-ID: <56A08E8F.7090602@mellanox.com>
References: <1453318816-21672-1-git-send-email-faisal.latif@intel.com>
 <CAJ3xEMhxMzAVJUNbBHrG8hia2tcFJ4cuPHpq3t9p0FqPHfYX+Q@mail.gmail.com>
 <00cf01d153d5$e6248eb0$b26dac10$@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: 'Or Gerlitz' <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	'Doug Ledford' <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	'Linux Netdev List' <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	'Jeff Kirsher' <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<e1000-rdma-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	'Faisal Latif' <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <00cf01d153d5$e6248eb0$b26dac10$@opengridcomputing.com>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 1/21/2016 12:57 AM, Steve Wise wrote:
> I also asked you why the port mapper code has to be present in each
> iwarp driver and not part of the IB core stack, and you responded
> "i40iw iwarp driver registers with port mapper and uses its services.
> Beside that it is not the scope of the patch series"  -- well, it is
> in the scope of upstream review to pose such questions, please
> address.
>
>
> There is a common service/API in the IB core for iWarp port mapping.  See drivers/infinbiand/core/iwpm*.c and include/rdma/iw_portmap.h.
>
>

Steve,

Okay, but I still don't follow why each vendor needs an RDMA_NL_YYY ID 
(RDMA_NL_C4IW, RDMA_NL_NES and now a new one  for this driver) of their own.

I see that the two current drivers actually use the same callbacks 
towards user-space, does each vendor uses a different user-space daemon, 
why?

Or.

net.git]# cd drivers/infiniband/hw/

hw]# git grep RDMA_NL_IWPM .
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

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
