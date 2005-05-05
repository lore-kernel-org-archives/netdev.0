From: Andre Tomt <andre@tomt.net>
Subject: Re: (diet-)FIB alternative fib_hlist.c
Date: Thu, 05 May 2005 21:54:49 +0200
Message-ID: <427A7A09.4060900@tomt.net>
References: <17016.62444.34282.625407@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Jens.Laas@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <17016.62444.34282.625407@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert Olsson wrote:
> Hello!
> 
> fib_hlist is the smallest and simpliest routing algo we could think of
> it's just a sorted (h)list.
> 
> routing (FIB lookup) performance. dst hash is not used.
> 
>     fib_hlist   fib_hash  test        routing table size 
>     -----------------------------------------------------
>     444 kpps    433 kpps  Single flow. local=19/main=5 entries
>     433 kpps    431 kpps  rDoS.        local=19/main=5
>     0.2 kpps    198 kpps  rDoS         local=19/main=123946
> 
> As seen fib_hlist is catastrophe for large routing tables as expected but 
> performs surprisingly well for ordinary routing tables so it should be 
> fine for most hosts and servers. The patch has config option to select FIB.
> 
> Probably we soon want to specify differnt lookup schemes for different 
> tables say for local table fib_hash or fib_hlist. While for large main table
> fib_hash2/fib_trie would be better option.

 From a distribution[1] point of view, a boot time option would be much 
better than choosing at compile time. Boot time plus a kconfig multiple 
selection list would be even better. Another perhaps even more user 
friendly option would be setting it runtime using f.ex. iproute, but I 
guess that could end up messy..

1. goes for both "a GNU/Linux distribution" and kernel image
    distribution in a production network
