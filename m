From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 8/8] bridge: Fix netpoll support
Date: Thu, 17 Jun 2010 20:38:19 +1000
Message-ID: <20100617103819.GA1252@gondor.apana.org.au>
References: <20100611021142.GA24490@gondor.apana.org.au> <E1OMtjm-0006PK-D6@gondolin.me.apana.org.au> <4C1755C1.3060804@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Qianfeng Zhang <frzhang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Matt Mackall <mpm@selenic.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:51739 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755140Ab0FQKia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jun 2010 06:38:30 -0400
Content-Disposition: inline
In-Reply-To: <4C1755C1.3060804@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 15, 2010 at 06:28:17PM +0800, Cong Wang wrote:
>
>> This allows us to do away with the npinfo juggling that caused
>> problem number 1.
>>
>> Incidentally this patch fixes number 2 by bypassing unsafe code
>> such as multicast snooping and netfilter.
>
> Not sure if I understand problem 2) and 3), this patch is not easy
> to review. So, what's the point of adding ->np to struct net_bridge_port?
> since we already have p->dev->npinfo->netpoll?

A netpoll_info structure always maps to one and only one net_device
structure.  While each net_device may have multiple netpoll
structures attached.

You must not share netpoll or netpoll_info structures between
devices since that breaks other users (netconsole or anything
else) from attaching to those devices.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
