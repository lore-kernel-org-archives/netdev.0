From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [ovs-dev] [PATCH net-next v3 1/8] netfilter: Remove
 IP_CT_NEW_REPLY definition.
Date: Thu, 26 Nov 2015 14:41:04 +0900
Message-ID: <20151126054100.GB21626@vergenet.net>
References: <1448496501-109561-1-git-send-email-jarno@ovn.org>
 <1448496501-109561-2-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	netfilter-devel@vger.kernel.org
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1448496501-109561-2-git-send-email-jarno@ovn.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 25, 2015 at 04:08:14PM -0800, Jarno Rajahalme wrote:
> Remove the definition of IP_CT_NEW_REPLY from the kernel as it does
> not make sense.  This allows the definition of IP_CT_NUMBER to be
> simplified as well.
> 
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>

I hate to be the bearer of bad news but its not clear
to me that this change doesn't break user-space.

> ---
>  include/uapi/linux/netfilter/nf_conntrack_common.h | 12 +++++++++---
>  net/openvswitch/conntrack.c                        |  2 --
>  2 files changed, 9 insertions(+), 5 deletions(-)
> 
> diff --git a/include/uapi/linux/netfilter/nf_conntrack_common.h b/include/uapi/linux/netfilter/nf_conntrack_common.h
> index 319f471..2f067cf 100644
> --- a/include/uapi/linux/netfilter/nf_conntrack_common.h
> +++ b/include/uapi/linux/netfilter/nf_conntrack_common.h
> @@ -20,9 +20,15 @@ enum ip_conntrack_info {
>  
>  	IP_CT_ESTABLISHED_REPLY = IP_CT_ESTABLISHED + IP_CT_IS_REPLY,
>  	IP_CT_RELATED_REPLY = IP_CT_RELATED + IP_CT_IS_REPLY,
> -	IP_CT_NEW_REPLY = IP_CT_NEW + IP_CT_IS_REPLY,	
> -	/* Number of distinct IP_CT types (no NEW in reply dirn). */
> -	IP_CT_NUMBER = IP_CT_IS_REPLY * 2 - 1
> +	/* No NEW in reply direction. */
> +
> +	/* Number of distinct IP_CT types. */
> +	IP_CT_NUMBER
> +
> +	/* only for userspace compatibility */
> +#ifndef __KERNEL__
> +	IP_CT_NEW_REPLY = IP_CT_NUMBER;
> +#endif
>  };
>  
>  #define NF_CT_STATE_INVALID_BIT			(1 << 0)
> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
> index c2cc111..a28a819 100644
> --- a/net/openvswitch/conntrack.c
> +++ b/net/openvswitch/conntrack.c
> @@ -73,7 +73,6 @@ static u8 ovs_ct_get_state(enum ip_conntrack_info ctinfo)
>  	switch (ctinfo) {
>  	case IP_CT_ESTABLISHED_REPLY:
>  	case IP_CT_RELATED_REPLY:
> -	case IP_CT_NEW_REPLY:
>  		ct_state |= OVS_CS_F_REPLY_DIR;
>  		break;
>  	default:
> @@ -90,7 +89,6 @@ static u8 ovs_ct_get_state(enum ip_conntrack_info ctinfo)
>  		ct_state |= OVS_CS_F_RELATED;
>  		break;
>  	case IP_CT_NEW:
> -	case IP_CT_NEW_REPLY:
>  		ct_state |= OVS_CS_F_NEW;
>  		break;
>  	default:
> -- 
> 2.1.4
> 
> _______________________________________________
> dev mailing list
> dev@openvswitch.org
> http://openvswitch.org/mailman/listinfo/dev
