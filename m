From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 8/8] bridge: Fix netpoll support
Date: Thu, 17 Jun 2010 18:57:28 +0800
Message-ID: <4C19FF98.5080105@redhat.com>
References: <20100611021142.GA24490@gondor.apana.org.au> <E1OMtjm-0006PK-D6@gondolin.me.apana.org.au> <4C1755C1.3060804@redhat.com> <20100617103819.GA1252@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Qianfeng Zhang <frzhang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Matt Mackall <mpm@selenic.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7463 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750701Ab0FQKxd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jun 2010 06:53:33 -0400
In-Reply-To: <20100617103819.GA1252@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/10 18:38, Herbert Xu wrote:
> On Tue, Jun 15, 2010 at 06:28:17PM +0800, Cong Wang wrote:
>>
>>> This allows us to do away with the npinfo juggling that caused
>>> problem number 1.
>>>
>>> Incidentally this patch fixes number 2 by bypassing unsafe code
>>> such as multicast snooping and netfilter.
>>
>> Not sure if I understand problem 2) and 3), this patch is not easy
>> to review. So, what's the point of adding ->np to struct net_bridge_port?
>> since we already have p->dev->npinfo->netpoll?
>
> A netpoll_info structure always maps to one and only one net_device
> structure.  While each net_device may have multiple netpoll
> structures attached.
>
> You must not share netpoll or netpoll_info structures between
> devices since that breaks other users (netconsole or anything
> else) from attaching to those devices.
>

Thanks for explanation.

Hmm, I get it now. So this helps to fix problem 3)?


