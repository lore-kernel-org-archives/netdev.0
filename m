From: Andrei Popa <andrei.popa@i-neo.ro>
Subject: Re: [oops] with FIB_TRIE
Date: Thu, 14 May 2009 14:54:58 +0300
Message-ID: <1242302098.3219.13.camel@ierdnac>
References: <1242041043.4619.56.camel@ierdnac>
	 <18953.37530.49022.415@robur.slu.se>
Reply-To: andrei.popa@i-neo.ro
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: NetDEV list <netdev@vger.kernel.org>
To: Robert Olsson <robert@robur.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 85-204-20-254.megainternet.ro ([85.204.20.254]:55446 "EHLO
	megainternet.ro" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754773AbZENL4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2009 07:56:51 -0400
In-Reply-To: <18953.37530.49022.415@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello,

I recompiled the kernel with FIB_TRIE and no preemption and it doesn't
oops anymore.

On Tue, 2009-05-12 at 17:15 +0200, Robert Olsson wrote:
> Andrei Popa writes:
> 
>  > I've used an vanilla 2.6.28.7 kernel without any additional patches with
>  > the following .config and when I do in quagga a "clear ip bgp * soft"
>  > when I have three full BGP sessions the kernel it oopses.
>  > 
>  > With FIB lookup algorithm FIB_TRIE it oopeses. With FIB_HASH it doesn't.
>  > 
>  > Pictures with the oops:
>  > http://89.33.136.9/oops/
> 
>  > The config file:
>  > CONFIG_PREEMPT=y
> 
>  Hello,
> 
>  Getting somewhat worried as we use this for infrastructure since many years. 
>  I've set up test and is trying to reproduce it. 
>  
>  I'm running forwarding ~9.4 Gigabit/s @ 1.2 pkts sec and fib_lookups 40-200.000
>  lookups per sec. Routing table has 280.000 entries this is loaded/unloaded 
>  via ip route with -batch to give load for insert/delete.
> 
>  A script is continuesly adding/removing the routing table under this load. 
>  The time to install the full table is ~10 sec and same time to remove
>  (without netfilter ~5 sec) And this during this constant traffic load.
> 
>  The scripts and routing tables:
>  ftp://robur.slu.se/pub/Linux/net-development/trie-test/
> 
>  Drivers are niu, ixgbe Netfilter modules loaded but no filters. Kernel 
>  2.6.29-r2. 
> 
>  No problems seen for 3 hours but I'll let this run overnight
> 
>  One difference to your config I see is PREEMPT. We use use 
>  CONFIG_PREEMPT_NONE=y with the router/servers.
> 
> 
>  Cheers
> 					--ro
> 

