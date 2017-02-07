From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v3 02/11] IB/hfi-vnic: Virtual Network Interface Controller
 (VNIC) interface
Date: Tue, 7 Feb 2017 14:06:30 -0800
Message-ID: <20170207220628.GB76652@knc-06.sc.intel.com>
References: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <1486498990-76562-3-git-send-email-niranjana.vishwanathapura@intel.com>
 <20170207211901.GB28922@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170207211901.GB28922-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 07, 2017 at 02:19:01PM -0700, Jason Gunthorpe wrote:
>On Tue, Feb 07, 2017 at 12:23:01PM -0800, Vishwanathapura, Niranjana wrote:
>> Add rdma netdev interface to ib device structure allowing rdma netdev
>> devices to be allocated by ib clients.
>> Define HFI VNIC interface between hardware independent VNIC
>> functionality and the hardware dependent VNIC functionality.
>
>This commit message could be a bit clearer.
>
>The alloc_rdma_netdev multiplexer is inteded as a new general
>interface and this adds a protocol definition for ethernet VNIC on
>OPA.
>

Ok, will add the statement to the commit message in PATCH series.

>The hope is that ipoib can follow the same example and use the same
>alloc_rdma_netdev entry point. Hopefully Mellanox will look at this
>patch as I have talked to them in the past about doing this...
>
>It looks like HFI turned out fairly well, the driver code and higher
>level code have a reasonably nice split in my quick look.
>

Yes, HFI_VNIC design is leaner now with standard netdev interface.

>>  	IB_DEVICE_RAW_SCATTER_FCS		= (1ULL << 34),
>> +	IB_DEVICE_RDMA_NETDEV_HFI_VNIC		= (1ULL << 35),
>
>What is this called HFI_VNIC anyhow? Shouldn't this be OPA_VNIC? There
>is nothing really HFI specific, right?
>

Agreed, OPA_VNIC is more appropriate here. Will change it.

>> +/* hfi vnic rdma netdev's private data structure */
>> +struct hfi_vnic_rdma_netdev {
>> +	struct rdma_netdev rn;  /* keep this first */
>> +	/* followed by device private data */
>> +	char *dev_priv[0];
>> +};
>> +
>> +static inline void *hfi_vnic_priv(const struct net_device *dev)
>> +{
>> +	struct rdma_netdev *rn = netdev_priv(dev);
>> +
>> +	return rn->clnt_priv;
>> +}
>> +
>> +static inline void *hfi_vnic_dev_priv(const struct net_device *dev)
>> +{
>> +	struct rdma_netdev *rn = netdev_priv(dev);
>
>Shouldn't this be hfi_vnic_rdma_netdev ?
>
>> +	return rn + 1;
>
>And this should be rn->dev_priv ?
>

Yah, both will result in same behavior. But yah, what you are suggesting will 
remove any confusion. Will change in next PATCH series.

Niranjana

>Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
