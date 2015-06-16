From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 06/11] IB/cma: Refactor RDMA IP CM private-data parsing
 code
Date: Tue, 16 Jun 2015 16:02:23 +0300
Message-ID: <55801E5F.2000002@mellanox.com>
References: <1434358036-15526-1-git-send-email-haggaie@mellanox.com>
 <1434358036-15526-7-git-send-email-haggaie@mellanox.com>
 <1828884A29C6694DAF28B7E6B8A82373A8FF5AD7@ORSMSX109.amr.corp.intel.com>
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
In-Reply-To: <1828884A29C6694DAF28B7E6B8A82373A8FF5AD7-P5GAC/sN6hkd3b2yrw5b5LfspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 16/06/2015 01:33, Hefty, Sean wrote:
>> -static int cma_save_net_info(struct rdma_cm_id *id, struct rdma_cm_id
>> *listen_id,
>> -			     struct ib_cm_event *ib_event)
>> +static u16 cma_port_from_service_id(__be64 service_id)
>>  {
>> -	struct cma_hdr *hdr;
>> +	return be64_to_cpu(service_id);
>> +}
> 
> Nit - Does the compiler not complain about the cast from u64 to u16?
> 

Apparently it does, but only with W=3 (-Wconversion is included there).
W=3 produces about 6k warnings when compiling cma.c, so I don't usually
enable it.

I'll add a cast there to prevent the warning.

Haggai
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
