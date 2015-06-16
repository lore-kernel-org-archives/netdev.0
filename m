From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 04/11] IB/cm: Expose DGID in SIDR request events
Date: Tue, 16 Jun 2015 09:51:43 +0300
Message-ID: <557FC77F.1090604@mellanox.com>
References: <1434358036-15526-1-git-send-email-haggaie@mellanox.com>
 <1434358036-15526-5-git-send-email-haggaie@mellanox.com>
 <1828884A29C6694DAF28B7E6B8A82373A8FF5A3F@ORSMSX109.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
To: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1828884A29C6694DAF28B7E6B8A82373A8FF5A3F-P5GAC/sN6hkd3b2yrw5b5LfspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 16/06/2015 00:32, Hefty, Sean wrote:
>>  drivers/infiniband/core/cm.c | 7 +++++++
>>  include/rdma/ib_cm.h         | 2 ++
>>  2 files changed, 9 insertions(+)
>>
>> diff --git a/drivers/infiniband/core/cm.c b/drivers/infiniband/core/cm.c
>> index c5f5f89e274a..46f99ec4080a 100644
>> --- a/drivers/infiniband/core/cm.c
>> +++ b/drivers/infiniband/core/cm.c
>> @@ -2983,6 +2983,13 @@ static void cm_format_sidr_req_event(struct cm_work
>> *work,
>>  	param->pkey = __be16_to_cpu(sidr_req_msg->pkey);
>>  	param->listen_id = listen_id;
>>  	param->service_id = sidr_req_msg->service_id;
>> +	if (work->mad_recv_wc->wc->wc_flags & IB_WC_GRH) {
>> +		param->grh = 1;
>> +		memcpy(&param->dgid, &work->mad_recv_wc->recv_buf.grh->dgid,
>> +		       sizeof(param->dgid));
>> +	} else {
>> +		param->grh = 0;
> 
> What is the use case here?  Are you trying to sort by device?  How does the GID of the GMP relate to the listen?

The idea is to allow SIDR request to be sorted by the GID, when we will
have alias GIDs for IPoIB.

Unlike the CM requests, SIDR requests do not contain the remote GID, so
I thought we could use the GID from the GRH and turn on GRH on such systems.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
