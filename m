From: "Rustad, Mark D" <mark.d.rustad-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: That's pretty much it for 3.5.0
Date: Wed, 18 Jul 2012 18:31:31 +0000
Message-ID: <FEB6B45E-1CCF-4CBC-AEB7-21D2088E175C@intel.com>
References: <5005D008.6060103@intel.com>
 <20120717.140241.1599386555723262095.davem@davemloft.net>
 <5005E390.7020706@intel.com>
 <20120717.151832.1306978935355646723.davem@davemloft.net>
 <5005F4F9.6010208@intel.com>
 <20120718130430.GE25563@hmsreliant.think-freely.org>
 <205259E8-A99F-4573-96C9-7A394235B338@intel.com>
 <1342634139.2626.3281.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"Fastabend, John R" <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"<h@hmsreliant.think-freely.org>" <h@hmsreliant.think-freely.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"<netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1342634139.2626.3281.camel@edumazet-glaptop>
Content-Language: en-US
Content-ID: <5E10377B5EA87A44A6BA98D972191549-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On Jul 18, 2012, at 10:55 AM, Eric Dumazet wrote:

> On Wed, 2012-07-18 at 17:36 +0000, Rustad, Mark D wrote:
>> 
>> The following change simply statically initializes init_net.dev_base_head. I copied and pasted it into the email, so this rendering may not work, but I can send it if this approach looks reasonable. I have verified that it resolves the issue above.
>> 
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 0f28a9e..db1ba61 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -6283,8 +6283,6 @@ static struct hlist_head *netdev_create_hash(void)
>> /* Initialize per network namespace state */
>> static int __net_init netdev_init(struct net *net)
>> {
>> -       INIT_LIST_HEAD(&net->dev_base_head);
>> -
> 
> 	if (net != &init_net)
> 		INIT_LIST_HEAD(&net->dev_base_head);

Ooooh. Good catch.

>>        net->dev_name_head = netdev_create_hash();
>>        if (net->dev_name_head == NULL)
>>                goto err_name;
>> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
>> index dddbacb..42f1e1c 100644
>> --- a/net/core/net_namespace.c
>> +++ b/net/core/net_namespace.c
>> @@ -27,7 +27,9 @@ static DEFINE_MUTEX(net_mutex);
>> LIST_HEAD(net_namespace_list);
>> EXPORT_SYMBOL_GPL(net_namespace_list);
>> 
>> -struct net init_net;
>> +struct net init_net = {
>> +       .dev_base_head = LIST_HEAD_INIT(init_net.dev_base_head),
>> +};
>> EXPORT_SYMBOL(init_net);
>> 
>> #define INITIAL_NET_GEN_PTRS   13 /* +1 for len +2 for rcu_head */


If this looks like a good change, I can send the patch. Is there any concern about init_net going from bss to data?

-- 
Mark Rustad, LAN Access Division, Intel Corporation

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
