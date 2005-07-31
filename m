From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Add prefetches in net/ipv4/route.c
Date: Sat, 30 Jul 2005 20:44:48 -0700 (PDT)
Message-ID: <20050730.204448.85713599.davem@davemloft.net>
References: <20050728.135826.63129319.davem@davemloft.net>
	<42E94D11.4090002@cosmosbay.com>
	<17130.16951.581026.863431@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert.Olsson@data.slu.se
In-Reply-To: <17130.16951.581026.863431@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Robert Olsson <Robert.Olsson@data.slu.se>
Date: Fri, 29 Jul 2005 16:50:31 +0200

>  My experiences from playing with prefetching eth_type_trans in this 
>  case. One must look in the total performance not just were the 
>  prefetching is done. In this case I was able to get eth_type_trans
>  down in the profile list but other functions increased so performance
>  was the same or lower. This needs to be sorted out... 

The problem is that if you just barely fit in the cache for a
workload, prefetches can hurt if done too early.  Let's say that your
code path needs to access data items A, B, and C, in that order.  If
you need to access A in order to know C, and subsequently if you
prefetch C before you use B, you might kick out B and end up making
performance worse (since you'll thus need to bring in C twice).

I really do not want to merge in any prefetch patches until
there is hard data showing an improvement, instead of some
shamanistic justification :-)

When the witch doctor comes to town and starts adding prefetches
all over the place without performance metrics, I become rightly
concerned.
