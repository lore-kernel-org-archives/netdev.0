From: David Miller <davem@davemloft.net>
Subject: Re: [RFC,PATCH] loopback: calls netif_receive_skb() instead of
 netif_rx()
Date: Mon, 31 Mar 2008 04:02:42 -0700 (PDT)
Message-ID: <20080331.040242.214941948.davem@davemloft.net>
References: <20080331094823.GA11651@elte.hu>
	<20080331.030848.175668431.davem@davemloft.net>
	<20080331104403.GA12681@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, a.p.zijlstra@chello.nl
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36786
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752050AbYCaLCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 07:02:41 -0400
In-Reply-To: <20080331104403.GA12681@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 31 Mar 2008 12:44:03 +0200

> and it's not just about scalability, the plain algorithmic overhead is 
> way too high as well:
> 
>  $ taskset 1 ./bw_tcp -s
>  $ taskset 1 ./bw_tcp localhost
>  Socket bandwidth using localhost: 2607.09 MB/sec
>  $ taskset 1 ./bw_pipe
>  Pipe bandwidth: 3680.44 MB/sec

Set your loopback MTU to some larger value if this result and
the locking overhead upsets you.

Also, woe be to the application that wants fast local interprocess
communication and doesn't use IPC_SHM, MAP_SHARED, pipes, or AF_UNIX
sockets.  (there's not just one better facility, there are _four_!)

>From this perspective, people way-overemphasize loopback performance,
and 999 times out of 1000 they prove their points using synthetic
benchmarks.

And don't give me this garbage about the application wanting to be
generic and therefore use IP sockets for everything.  Either they want
to be generic, or they want the absolute best performance.  Trying
to get an "or" and have both at the same time will result in
ludicrious hacks ending up in the kernel.
