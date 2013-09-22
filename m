From: Anirban Chakraborty <abchak@juniper.net>
Subject: Re: [PATCH net-next] xen-netfront: convert to GRO API and advertise
 this feature
Date: Sun, 22 Sep 2013 23:09:35 +0000
Message-ID: <D310C490-3B7D-4937-95DC-AFC1682B60BE@juniper.net>
References: <1379779543-27122-1-git-send-email-wei.liu2@citrix.com>
 <1379861723.3431.10.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Wei Liu <wei.liu2@citrix.com>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	"<xen-devel@lists.xen.org>" <xen-devel@lists.xen.org>,
	Ian Campbell <ian.campbell@citrix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe001.messaging.microsoft.com ([216.32.180.184]:52245
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752340Ab3IVXJl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Sep 2013 19:09:41 -0400
In-Reply-To: <1379861723.3431.10.camel@edumazet-glaptop>
Content-Language: en-US
Content-ID: <5D5580385783D147BB6F04707B1B07C8@namprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sep 22, 2013, at 7:55 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Sat, 2013-09-21 at 17:05 +0100, Wei Liu wrote:
>> Anirban was seeing netfront received MTU size packets, which downgraded
>> throughput. The following patch makes netfront use GRO API which
>> improves throughput for that case.
> 
>> -	netdev->hw_features	= NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO;
>> +	netdev->hw_features	= NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO |
>> +				  NETIF_F_GRO;
> 
> 
> This part is not needed.

Shouldn't the flag be set? In dev_gro_receive() we do check if this flag is set or not:

        if (!(skb->dev->features & NETIF_F_GRO) || netpoll_rx_on(skb))
               goto normal;

-Anirban
