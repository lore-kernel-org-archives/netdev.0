From: Anirban Chakraborty <abchak@juniper.net>
Subject: Re: [PATCH net-next] xen-netfront: convert to GRO API
 and advertise this feature
Date: Mon, 23 Sep 2013 20:27:26 +0000
Message-ID: <A3521C70-77D5-4219-8C8B-6137E7931DE5@juniper.net>
References: <1379779543-27122-1-git-send-email-wei.liu2@citrix.com>
	<1379861723.3431.10.camel@edumazet-glaptop>
	<D310C490-3B7D-4937-95DC-AFC1682B60BE@juniper.net>
	<1379915907.3165.5.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>, Ian Campbell <ian.campbell@citrix.com>,
	"<xen-devel@lists.xen.org>" <xen-devel@lists.xen.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1379915907.3165.5.camel@edumazet-glaptop>
Content-Language: en-US
Content-ID: <ADEAF07999043641830DDE56CF7BB0C7@namprd05.prod.outlook.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org


On Sep 22, 2013, at 10:58 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Sun, 2013-09-22 at 23:09 +0000, Anirban Chakraborty wrote:
>> On Sep 22, 2013, at 7:55 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> 
>>> On Sat, 2013-09-21 at 17:05 +0100, Wei Liu wrote:
>>>> Anirban was seeing netfront received MTU size packets, which downgraded
>>>> throughput. The following patch makes netfront use GRO API which
>>>> improves throughput for that case.
>>> 
>>>> -	netdev->hw_features	= NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO;
>>>> +	netdev->hw_features	= NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO |
>>>> +				  NETIF_F_GRO;
>>> 
>>> 
>>> This part is not needed.
>> 
>> Shouldn't the flag be set? In dev_gro_receive() we do check if this flag is set or not:
>> 
>>        if (!(skb->dev->features & NETIF_F_GRO) || netpoll_rx_on(skb))
>>               goto normal;
> 
> Drivers do not set NETIF_F_GRO themselves, they do not need to.
> 
> Look at other drivers which are GRO ready : NETIF_F_GRO is enabled by
> default by core networking stack, in register_netdevice()
> 
> 
> dev->hw_features |= NETIF_F_SOFT_FEATURES;
> dev->features |= NETIF_F_SOFT_FEATURES;

I didn't realize that the drivers no longer need to set the GRO flag explicitly. It looks like it has been changed since 3.2. I was looking at the kernel version 2.6.32.43 (which corresponds to the dom0 kernel) where the problem is happening. 

-Anirban
