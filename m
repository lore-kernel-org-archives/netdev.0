From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] Add prefetches in net/ipv4/route.c
Date: Fri, 29 Jul 2005 10:06:10 -0700
Message-ID: <42EA6202.703@hp.com>
References: <42E8FF24.9070009@cosmosbay.com>	<20050728.123922.126777020.davem@davemloft.net>	<42E94680.8060309@cosmosbay.com>	<20050728.135826.63129319.davem@davemloft.net>	<42E94D11.4090002@cosmosbay.com> <17130.16951.581026.863431@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <17130.16951.581026.863431@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert Olsson wrote:
> Eric Dumazet writes:
> 
>  > I have no profiling info for this exact patch, I'm sorry David.
>  > On a dual opteron machine, this thing from ip_route_input() is very expensive :
>  > 
>  >   RT_CACHE_STAT_INC(in_hlist_search);
>  > 
>  > ip_route_input() use a total of 3.4563 % of one cpu, but this 'increment' takes 1.20 % !!!
> 
>  Very weird if the statscounter taking a third of ip_route_input.
> 
>  > Sometime I wonder if oprofile can be trusted :(
>  > 
>  > Maybe we should increment a counter on the stack and do a final
>  >     if (counter != 0)
>  >         RT_CACHE_STAT_ADD(in_hlist_search, counter);
> 
>  My experiences from playing with prefetching eth_type_trans in this 
>  case. One must look in the total performance not just were the 
>  prefetching is done. In this case I was able to get eth_type_trans
>  down in the profile list but other functions increased so performance
>  was the same or lower. This needs to be sorted out... 

How many of the architectures have PMU's that can give us cache miss statistics? 
  Itanium does, and can go so far as to tell us which addresses and instructions 
are involved - do the others?

That sort of data would seem to be desirable in this sort of situation.

rick jones
