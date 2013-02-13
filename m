From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v4 4/9] rdma/cm: Update port reservation to support AF_IB
Date: Wed, 13 Feb 2013 13:09:40 +0200
Message-ID: <511B7474.3040201@mellanox.com>
References: <1358891797-14625-1-git-send-email-sean.hefty@intel.com> <1358891797-14625-5-git-send-email-sean.hefty@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1358891797-14625-5-git-send-email-sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 22/01/2013 23:56, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org wrote:
> The AF_IB uses a 64-bit service id (SID), which the
> user can control through the use of a mask.  The rdma_cm
> will assign values to the unmasked portions of the SID
> based on the selected port space and port number.

Something here I am not sure to follow -- if AF_IB consumers are allowed 
to provide 64-bit SID, how
the IB port space is expressed in their SIDs?

Wouldn't it make sense to use a simpler approach that has a dedicated 
IB_PS in the port space
portion of the RDMA-CM IP IBTA annex and let the consumer provide 16 
bits for their part of the SID?

Or.


> Because the IB spec divides the SID range into several regions,
> a SID/mask combination may fall into one of the existing
> port space ranges as defined by the RDMA CM IP Annex.  Map
> the AF_IB SID to the correct RDMA port space.

> [...]
> --- a/include/rdma/rdma_cm.h
> +++ b/include/rdma/rdma_cm.h
> @@ -70,6 +70,11 @@ enum rdma_port_space {
>   	RDMA_PS_UDP   = 0x0111,
>   };
>   
> +#define RDMA_IB_IP_PS_MASK   0xFFFFFFFFFFFF0000ULL
> +#define RDMA_IB_IP_PS_TCP    0x0000000001060000ULL
> +#define RDMA_IB_IP_PS_UDP    0x0000000001110000ULL
> +#define RDMA_IB_IP_PS_IB     0x00000000013F0000ULL
>

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
