From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: Re: [patch net-next RFC 03/12] net: introduce generic
 switch devices support
Date: Tue, 26 Aug 2014 10:34:52 +0200
Message-ID: <20140826083452.GR1878@nanopsycho.lan>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
 <1408637945-10390-4-git-send-email-jiri@resnulli.us>
 <20140824114605.GC32741@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org,
 buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
 aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org,
 dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140824114605.GC32741-FZi0V3Vbi30CUdFEqe4BF2D2FQJk+8+b@public.gmane.org>
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

Sun, Aug 24, 2014 at 01:46:05PM CEST, tgraf-G/eBtMaohhA@public.gmane.org wrote:
>On 08/21/14 at 06:18pm, Jiri Pirko wrote:
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 39294b9..8b5d14c 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -49,6 +49,8 @@
>>  
>>  #include <linux/netdev_features.h>
>>  #include <linux/neighbour.h>
>> +#include <linux/sw_flow.h>
>> +
>>  #include <uapi/linux/netdevice.h>
>>  
>>  struct netpoll_info;
>> @@ -997,6 +999,24 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>> + * int (*ndo_swdev_flow_insert)(struct net_device *dev,
>> + *				const struct sw_flow *flow);
>> + *	Called to insert a flow into switch device. If driver does
>> + *	not implement this, it is assumed that the hw does not have
>> + *	a capability to work with flows.
>
>I asume you are planning to add an additional expandable struct
>paramter to handle insertion parameters when the first is introduced
>to avoid requiring to touch every driver every time.

Sure. That is the way to go.

>
>> +/**
>> + *	swdev_flow_insert - Insert a flow into switch
>> + *	@dev: port device
>> + *	@flow: flow descriptor
>> + *
>> + *	Insert a flow into switch this port is part of.
>> + */
>> +int swdev_flow_insert(struct net_device *dev, const struct sw_flow *flow)
>> +{
>> +	const struct net_device_ops *ops = dev->netdev_ops;
>> +
>> +	print_flow(flow, dev, "insert");
>> +	if (!ops->ndo_swdev_flow_insert)
>> +		return -EOPNOTSUPP;
>> +	WARN_ON(!ops->ndo_swdev_get_id);
>> +	BUG_ON(!flow->actions);
>> +	return ops->ndo_swdev_flow_insert(dev, flow);
>> +}
>> +EXPORT_SYMBOL(swdev_flow_insert);
>
>Splitting the flow specific API into a separate file (maybe
>swdev_flow.c?) might help resolve some of the concerns around the
>focus on flows. It would make it clear that it's one of multiple
>models to be supported.

I understand your point. But the file is tiny as it is. I would keep all
in one file for now.
