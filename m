From: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Subject: Re: [RFC PATCH 08/11] IB/Verbs: Use management helper has_iwarp()
 for, iwarp-check
Date: Mon, 30 Mar 2015 18:21:55 +0200
Message-ID: <55197823.9070006@profitbricks.com>
References: <551579CA.4030901@profitbricks.com>	 <55157B98.1060103@profitbricks.com> <1427731980.21101.199.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Moni Shoua <monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	PJ Waskiewicz <pj.waskiewicz-PrFOU5CTvK1l57MIdRCFDg@public.gmane.org>,
	Tatyana Nikolova <Tatyana.E.Nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Yan Burman <yanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>,
	Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>,
	Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Majd Dibbiny <majd-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Alex Estrin <alex.estrin@int
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1427731980.21101.199.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/30/2015 06:13 PM, Doug Ledford wrote:
> On Fri, 2015-03-27 at 16:47 +0100, Michael Wang wrote:
>> Introduce helper has_iwarp() to help us check if an IB device
>> support IWARP protocol.
> This is a needless redirection.  Just stick with the original
> rdma_transport_is_iwarp().

Agree, will leave it there :-)

Regards,
Michael Wang

>
>> Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
>> Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>> Cc: Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>> Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>> Signed-off-by: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
>> ---
>>  include/rdma/ib_verbs.h                 | 13 +++++++++++++
>>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |  2 +-
>>  2 files changed, 14 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
>> index e796104..0ef9cd7 100644
>> --- a/include/rdma/ib_verbs.h
>> +++ b/include/rdma/ib_verbs.h
>> @@ -1836,6 +1836,19 @@ static inline int has_mcast(struct ib_device *device)
>>  }
>>  
>>  /**
>> + * has_iwarp - Check if a device support IWARP protocol.
>> + *
>> + * @device: Device to be checked
>> + *
>> + * Return 0 when a device has none port to support
>> + * IWARP protocol.
>> + */
>> +static inline int has_iwarp(struct ib_device *device)
>> +{
>> +    return rdma_transport_is_iwarp(device);
>> +}
>> +
>> +/**
>>   * cap_smi - Check if the port of device has the capability
>>   * Subnet Management Interface.
>>   *
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>> index a7b5891..48aeb5e 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>> @@ -118,7 +118,7 @@ static void rdma_build_arg_xdr(struct svc_rqst *rqstp,
>>  
>>  static int rdma_read_max_sge(struct svcxprt_rdma *xprt, int sge_count)
>>  {
>> -    if (rdma_transport_is_iwarp(xprt->sc_cm_id->device))
>> +    if (has_iwarp(xprt->sc_cm_id->device))
>>          return 1;
>>      else
>>          return min_t(int, sge_count, xprt->sc_max_sge);
>

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
