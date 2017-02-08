From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v3 02/11] IB/hfi-vnic: Virtual Network Interface Controller
 (VNIC) interface
Date: Tue, 7 Feb 2017 17:12:46 -0800
Message-ID: <20170208011246.GC76793@knc-06.sc.intel.com>
References: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <1486498990-76562-3-git-send-email-niranjana.vishwanathapura@intel.com>
 <VI1PR0502MB3008911E9587F4C004BFEF13D1420@VI1PR0502MB3008.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Parav Pandit <parav-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <VI1PR0502MB3008911E9587F4C004BFEF13D1420-o1MPJYiShExKsLr+rGaxW8DSnupUy6xnnBOFsp37pqbUKgpGm//BTAC/G2K4zDHf@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 08, 2017 at 12:43:40AM +0000, Parav Pandit wrote:
>> @@ -2096,6 +2114,15 @@ struct ib_device {
>>  							   struct
>> ib_rwq_ind_table_init_attr *init_attr,
>>  							   struct ib_udata
>> *udata);
>>  	int                        (*destroy_rwq_ind_table)(struct ib_rwq_ind_table
>> *wq_ind_table);
>> +	/* rdma netdev operations */
>> +	struct net_device *(*alloc_rdma_netdev)(
>> +					struct ib_device *device,
>> +					u8 port_num,
>> +					enum rdma_netdev_t type,
>> +					const char *name,
>> +					unsigned char name_assign_type,
>> +					void (*setup)(struct net_device *));
>> +	void (*free_rdma_netdev)(struct net_device *netdev);
>>  	struct ib_dma_mapping_ops   *dma_ops;
>>
>>  	struct module               *owner;
>
>As its clear from the cover letter and from the request to place this in drivers/infiniband/ulp,
>Instead of increasing the ib_dev structure further,
>Can you change the code to make use of ib_register_client() and friend functions to register vnic as ULP.
>(similar to other ULP such as uverbs, srp, ipoib).
>This will also allow you get to get notified for removing the vnic device when underlying rdma device gets removed.
>Based on the property that gets exposed by the ibdev, vnic driver filters whether it needs to load its vnic to specific device or not.
>This way modules are isolated between core and ULP little better.
>Would it work for you?

HFI_VNIC driver is using ib_register_client() and friend fucntions. Below patch 
in this series does that.
[RFC v3 08/11] IB/hfi-vnic: VNIC Ethernet Management Agent (VEMA) function

Niranjana

>
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
