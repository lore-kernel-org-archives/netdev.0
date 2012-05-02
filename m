From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH 3/4 v2 net-next] net: make GRO aware of skb->head_frag
Date: Wed, 02 May 2012 09:16:30 -0700
Message-ID: <4FA15DDE.5090904@intel.com>
References: <1335523026.2775.236.camel@edumazet-glaptop>  <1335809434.2296.9.camel@edumazet-glaptop> <4F9F21E2.3080407@intel.com>  <1335835677.11396.5.camel@edumazet-glaptop>  <CAKgT0UdeVvJe6k5OitkKgujSw3SQSOvtQ84KrPch8xdd=5ub1A@mail.gmail.com>  <1335854378.11396.26.camel@edumazet-glaptop>  <4FA00C9F.8080409@intel.com>  <1335891892.22133.23.camel@edumazet-glaptop>  <4FA03D69.6060907@intel.com> <1335947084.22133.134.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	=?UTF-8?B?SWxwbyBKw6RydmluZW4=?= <ilpo.jarvinen@helsinki.fi>,
	=?UTF-8?B?TWFjaWVqIMW7ZW5jenlrb3dza2k=?= <maze@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:55821 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752711Ab2EBQQe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2012 12:16:34 -0400
In-Reply-To: <1335947084.22133.134.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/02/2012 01:24 AM, Eric Dumazet wrote:
> On Tue, 2012-05-01 at 12:45 -0700, Alexander Duyck wrote:
>
>> I have a hacked together ixgbe up and running now with the new build_skb
>> logic and RSC/LRO disabled.  It looks like it is giving me a 5%
>> performance boost for small packet routing, but I am using more CPU for
>> netperf TCP receive tests and I was wondering if you had seen anything
>> similar on the tg3 driver?
> Really hard to say, numbers are so small on Gb link :
>
> what do you use to make your numbers ?
>
> netperf -H 172.30.42.23 -t OMNI -C -c 
> OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.30.42.23 (172.30.42.23) port 0 AF_INET
> Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
> Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
> Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
> Final       Final                                             %     Method %      Method                          
> 1700840     1700840     16384  10.01   931.60     10^6bits/s  4.50  S      1.32   S      1.582   2.783   usec/KB  
>
> About ixgbe, feel free to send your patch ;)
>
> Thanks !
>
>
I was working with the out-of-tree ixgbe because I have the option there
of stripping out FCoE and RSC via a couple of build flags.  The problem
is I don't know if the head frag stuff will work out very well with
ixgbe because RSC and FCoE require that we have to use 1K aligned
receive buffers.  It would require us to make us have to bump up our
allocation size by NET_SKB_PAD plus skb_shared_info which would likely
force us up to order 1 pages on most platforms.

Thanks,

Alex
