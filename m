From: Dennis Dalessandro <dennis.dalessandro@intel.com>
Subject: Re: [PATCH rdma-next V2 25/27] RDMA/netlink: Export LID mask counter
 (LMC)
Date: Mon, 17 Jul 2017 11:14:28 -0400
Message-ID: <04e53968-c2e9-17b0-c51e-80a038e23711@intel.com>
References: <20170703062830.30361-1-leon@kernel.org>
 <20170703062830.30361-26-leon@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Ariel Almog <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>
To: Leon Romanovsky <leon@kernel.org>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:6432 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751278AbdGQPOa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Jul 2017 11:14:30 -0400
In-Reply-To: <20170703062830.30361-26-leon@kernel.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/3/2017 2:28 AM, Leon Romanovsky wrote:
> From: Leon Romanovsky <leonro@mellanox.com>
> 
> Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
> ---
>   drivers/infiniband/core/nldev.c  | 3 +++
>   include/uapi/rdma/rdma_netlink.h | 5 +++++
>   2 files changed, 8 insertions(+)
> 
> diff --git a/drivers/infiniband/core/nldev.c b/drivers/infiniband/core/nldev.c
> index ce733bf33ed9..f968a40ef5d3 100644
> --- a/drivers/infiniband/core/nldev.c
> +++ b/drivers/infiniband/core/nldev.c
> @@ -47,6 +47,7 @@ static const struct nla_policy nldev_policy[RDMA_NLDEV_ATTR_MAX] = {
>   	[RDMA_NLDEV_ATTR_SUBNET_PREFIX]	= { .type = NLA_U64 },
>   	[RDMA_NLDEV_ATTR_LID]		= { .type = NLA_U32 },
>   	[RDMA_NLDEV_ATTR_SM_LID]	= { .type = NLA_U32 },
> +	[RDMA_NLDEV_ATTR_LMC]		= { .type = NLA_U8 },
>   };
>   
>   static int fill_dev_info(struct sk_buff *msg, struct ib_device *device)
> @@ -109,6 +110,8 @@ static int fill_port_info(struct sk_buff *msg,
>   			return -EMSGSIZE;
>   		if (nla_put_u32(msg, RDMA_NLDEV_ATTR_SM_LID, attr.sm_lid))
>   			return -EMSGSIZE;
> +		if (nla_put_u8(msg, RDMA_NLDEV_ATTR_LMC, attr.lmc))
> +			return -EMSGSIZE;
>   	}
>   	return 0;
>   }
> diff --git a/include/uapi/rdma/rdma_netlink.h b/include/uapi/rdma/rdma_netlink.h
> index 82e0d64346e1..d4b862e8ed15 100644
> --- a/include/uapi/rdma/rdma_netlink.h
> +++ b/include/uapi/rdma/rdma_netlink.h
> @@ -292,6 +292,11 @@ enum rdma_nldev_attr {
>   	RDMA_NLDEV_ATTR_LID,			/* u32 */
>   	RDMA_NLDEV_ATTR_SM_LID,			/* u32 */
>   
> +	/*
> +	 * LID mask count (LMC)
> +	 */
> +	RDMA_NLDEV_ATTR_LMC,			/* u8 */
> +
>   	RDMA_NLDEV_ATTR_MAX
>   };
>   #endif /* _UAPI_RDMA_NETLINK_H */
> 

LMC = "Counter" or "Control"? I always thought it was the latter.

-Denny
