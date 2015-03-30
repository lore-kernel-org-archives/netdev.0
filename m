From: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Subject: Re: [RFC PATCH 02/11] IB/Verbs: Use management helper tech_iboe()
 for iboe-check
Date: Mon, 30 Mar 2015 18:23:16 +0200
Message-ID: <55197874.3080807@profitbricks.com>
References: <551579CA.4030901@profitbricks.com>	 <55157A4F.1090301@profitbricks.com> <1427732250.21101.202.camel@redhat.com>
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
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1427732250.21101.202.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/30/2015 06:17 PM, Doug Ledford wrote:
> On Fri, 2015-03-27 at 16:42 +0100, Michael Wang wrote:
>> Introduce helper tech_iboe() to help us check if the port of an IB
>> device is using RoCE/IBoE technology.
> Just use rdma_transport_is_roce() instead.
Sounds good :-) will be in next version.

Regards,
Michael Wang

>
>> Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
>> Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>> Cc: Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>> Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>> Signed-off-by: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
>> ---
>>  drivers/infiniband/core/cma.c |  6 ++----
>>  include/rdma/ib_verbs.h       | 16 ++++++++++++++++
>>  2 files changed, 18 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
>> index 668e955..280cfe3 100644
>> --- a/drivers/infiniband/core/cma.c
>> +++ b/drivers/infiniband/core/cma.c
>> @@ -375,8 +375,7 @@ static int cma_acquire_dev(struct rdma_id_private *id_priv,
>>                       listen_id_priv->id.port_num) == dev_ll) {
>>          cma_dev = listen_id_priv->cma_dev;
>>          port = listen_id_priv->id.port_num;
>> -        if (rdma_transport_is_ib(cma_dev->device) &&
>> -            rdma_port_ll_is_eth(cma_dev->device, port))
>> +        if (tech_iboe(cma_dev->device, port))
>>              ret = ib_find_cached_gid(cma_dev->device, &iboe_gid,
>>                           &found_port, NULL);
>>          else
>> @@ -395,8 +394,7 @@ static int cma_acquire_dev(struct rdma_id_private *id_priv,
>>                  listen_id_priv->id.port_num == port)
>>                  continue;
>>              if (rdma_port_get_link_layer(cma_dev->device, port) == dev_ll) {
>> -                if (rdma_transport_is_ib(cma_dev->device) &&
>> -                    rdma_port_ll_is_eth(cma_dev->device, port))
>> +                if (tech_iboe(cma_dev->device, port))
>>                      ret = ib_find_cached_gid(cma_dev->device, &iboe_gid, &found_port, NULL);
>>                  else
>>                      ret = ib_find_cached_gid(cma_dev->device, &gid, &found_port, NULL);
>> diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
>> index 2bf9094..ca6d6bc 100644
>> --- a/include/rdma/ib_verbs.h
>> +++ b/include/rdma/ib_verbs.h
>> @@ -1767,6 +1767,22 @@ static inline int rdma_port_ll_is_eth(struct ib_device *device, u8 port_num)
>>              == IB_LINK_LAYER_ETHERNET;
>>  }
>>  
>> +/**
>> + * tech_iboe - Check if the port of device using technology
>> + * RoCE/IBoE.
>> + *
>> + * @device: Device to be checked
>> + * @port_num: Port number of the device
>> + *
>> + * Return 0 when port of the device is not using technology
>> + * RoCE/IBoE.
>> + */
>> +static inline int tech_iboe(struct ib_device *device, u8 port_num)
>> +{
>> +    return rdma_transport_is_ib(device) &&
>> +            rdma_port_ll_is_eth(device, port_num);
>> +}
>> +
>>  int ib_query_gid(struct ib_device *device,
>>           u8 port_num, int index, union ib_gid *gid);
>>  
>

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
