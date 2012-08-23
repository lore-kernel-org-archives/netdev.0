From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [patch net-next 2/3] vlan: add helper which can be called to
 se it device is used by vlan
Date: Thu, 23 Aug 2012 16:33:06 +0300
Message-ID: <50363112.4060407@mellanox.com>
References: <1345728413-10298-1-git-send-email-jiri@resnulli.us> <1345728413-10298-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<brouer@redhat.com>, Patrick McHardy <kaber@trash.net>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:53352 "HELO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758806Ab2HWNdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 09:33:18 -0400
In-Reply-To: <1345728413-10298-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/08/2012 16:26, Jiri Pirko wrote:
> also, remove unused vlan_info definition from header

just a typo in the subject line, you probably wanted to say "see" and 
not "se"?

Or.

>
> CC: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>   include/linux/if_vlan.h | 9 +++++++--
>   net/8021q/vlan_core.c   | 6 ++++++
>   2 files changed, 13 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
> index a810987..e6ff12d 100644
> --- a/include/linux/if_vlan.h
> +++ b/include/linux/if_vlan.h
> @@ -74,8 +74,6 @@ static inline struct vlan_ethhdr *vlan_eth_hdr(const struct sk_buff *skb)
>   /* found in socket.c */
>   extern void vlan_ioctl_set(int (*hook)(struct net *, void __user *));
>   
> -struct vlan_info;
> -
>   static inline int is_vlan_dev(struct net_device *dev)
>   {
>           return dev->priv_flags & IFF_802_1Q_VLAN;
> @@ -101,6 +99,8 @@ extern int vlan_vids_add_by_dev(struct net_device *dev,
>   				const struct net_device *by_dev);
>   extern void vlan_vids_del_by_dev(struct net_device *dev,
>   				 const struct net_device *by_dev);
> +
> +extern bool vlan_uses_dev(const struct net_device *dev);
>   #else
>   static inline struct net_device *
>   __vlan_find_dev_deep(struct net_device *real_dev, u16 vlan_id)
> @@ -151,6 +151,11 @@ static inline void vlan_vids_del_by_dev(struct net_device *dev,
>   					const struct net_device *by_dev)
>   {
>   }
> +
> +static inline bool vlan_uses_dev(const struct net_device *dev)
> +{
> +	return false;
> +}
>   #endif
>   
>   /**
> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
> index d4babc6..517b940 100644
> --- a/net/8021q/vlan_core.c
> +++ b/net/8021q/vlan_core.c
> @@ -372,3 +372,9 @@ void vlan_vids_del_by_dev(struct net_device *dev,
>   		vlan_vid_del(dev, vid_info->vid);
>   }
>   EXPORT_SYMBOL(vlan_vids_del_by_dev);
> +
> +bool vlan_uses_dev(const struct net_device *dev)
> +{
> +	return rtnl_dereference(dev->vlan_info) ? true : false;
> +}
> +EXPORT_SYMBOL(vlan_uses_dev);
