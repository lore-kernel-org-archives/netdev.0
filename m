From: John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [patch net-next 03/13] net: introduce generic switch
 devices support
Date: Wed, 03 Sep 2014 08:46:23 -0700
Message-ID: <540737CF.4000402@gmail.com>
References: <1409736300-12303-1-git-send-email-jiri@resnulli.us>
 <1409736300-12303-4-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org,
 buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
 aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org,
 dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1409736300-12303-4-git-send-email-jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 09/03/2014 02:24 AM, Jiri Pirko wrote:
> The goal of this is to provide a possibility to suport various switch
> chips. Drivers should implement relevant ndos to do so. Now there is a
> couple of ndos defines:
> - for getting physical switch id is in place.
> - for work with flows.
>
> Note that user can use random port netdevice to access the switch.
>
> Signed-off-by: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
> ---


[...]

>   struct netpoll_info;
> @@ -997,6 +999,24 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>    *	Callback to use for xmit over the accelerated station. This
>    *	is used in place of ndo_start_xmit on accelerated net
>    *	devices.
> + *
> + * int (*ndo_swdev_get_id)(struct net_device *dev,
> + *			   struct netdev_phys_item_id *psid);
> + *	Called to get an ID of the switch chip this port is part of.
> + *	If driver implements this, it indicates that it represents a port
> + *	of a switch chip.
> + *
> + * int (*ndo_swdev_flow_insert)(struct net_device *dev,
> + *				const struct sw_flow *flow);
> + *	Called to insert a flow into switch device. If driver does
> + *	not implement this, it is assumed that the hw does not have
> + *	a capability to work with flows.
> + *
> + * int (*ndo_swdev_flow_remove)(struct net_device *dev,
> + *				const struct sw_flow *flow);
> + *	Called to remove a flow from switch device. If driver does
> + *	not implement this, it is assumed that the hw does not have
> + *	a capability to work with flows.
>    */
>   struct net_device_ops {
>   	int			(*ndo_init)(struct net_device *dev);
> @@ -1146,6 +1166,14 @@ struct net_device_ops {
>   							struct net_device *dev,
>   							void *priv);
>   	int			(*ndo_get_lock_subclass)(struct net_device *dev);
> +#ifdef CONFIG_NET_SWITCHDEV
> +	int			(*ndo_swdev_get_id)(struct net_device *dev,
> +						    struct netdev_phys_item_id *psid);
> +	int			(*ndo_swdev_flow_insert)(struct net_device *dev,
> +							 const struct sw_flow *flow);
> +	int			(*ndo_swdev_flow_remove)(struct net_device *dev,
> +							 const struct sw_flow *flow);

Not really a critique of your patch but I'll need to extend this
with a ndo_swdev_flow_dump() to get the fields. Without this if
your user space side ever restarts, gets out of sync there is no
way to get back in sync.

Also with hardware that has multiple flow tables we need to indicate
the table to insert the flow into. One concrete reason to do this
is to create atomic updates of multiple ACLs. The idea is to create
a new ACL table build the table up and then link it in. This can be
added when its needed my opensource drivers don't support this yet
either but maybe adding multiple tables to rocker switch will help
flush this out.

Finally we need some way to drive capabilities out of the swdev.
Even rocker switch needs this to indicate it doesn't support matching
on all the sw_flow fields. Without this its not clear to me how to
manage the device from user space. I tried writing user space daemon
for the simpler flow director interface and the try and see model
breaks quickly.

> +#endif
>   };
>
>   /**
> diff --git a/include/net/sw_flow.h b/include/net/sw_flow.h
> index 21724f1..3af7758 100644
> --- a/include/net/sw_flow.h
> +++ b/include/net/sw_flow.h
> @@ -81,7 +81,21 @@ struct sw_flow_mask {
>   	struct sw_flow_key key;
>   };
>
> +enum sw_flow_action_type {
> +	SW_FLOW_ACTION_TYPE_OUTPUT,
> +	SW_FLOW_ACTION_TYPE_VLAN_PUSH,
> +	SW_FLOW_ACTION_TYPE_VLAN_POP,
> +};
> +

OK my previous comment about having another patch to create
generic actions seems to be resolved here. I'm not sure how
important it is but if we abstract the flow types away from
OVS is there any reason not to reuse and relabel the action
types as well? I guess we can't break userspace API but maybe
a 1:1 mapping would be better?

>   struct sw_flow_action {
> +	enum sw_flow_action_type type;
> +	union {
> +		u32 out_port_ifindex;
> +		struct {
> +			__be16 vlan_proto;
> +			u16 vlan_tci;
> +		} vlan;
> +	};
>   };

[...]

I think my comments could be addressed with additional patches
if you want. I could help but it will be another week or so
before I have some time. The biggest issue IMO is the lack of
capabilities queries.

Thanks,
John


-- 
John Fastabend         Intel Corporation
