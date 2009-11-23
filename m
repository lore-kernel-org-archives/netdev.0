From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: ixgbe question
Date: Mon, 23 Nov 2009 15:10:24 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0911231500060.24347@ask.diku.dk>
References: <20091123064630.7385.30498.stgit@ppwaskie-hc2.jf.intel.com>
 <2674af740911222332i65c0d066h79bf2c1ca1d5e4f0@mail.gmail.com>
 <1258968980.2697.9.camel@ppwaskie-mobl2> <4B0A6218.9040303@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:54534 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754760AbZKWOKV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2009 09:10:21 -0500
In-Reply-To: <4B0A6218.9040303@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 23 Nov 2009, Eric Dumazet wrote:

> I tried a pktgen stress on 82599EB card and could not split RX load on multiple cpus.
>
> Setup is :
>
> One 82599 card with fiber0 looped to fiber1, 10Gb link mode.
> machine is a HPDL380 G6 with dual quadcore E5530 @2.4GHz (16 logical cpus)
>
> I use one pktgen thread sending to fiber0 one many dst IP, and checked that fiber1
> was using many RX queues :

How is your smp_affinity mask's set?

grep . /proc/irq/*/fiber1-*/../smp_affinity


> But only one CPU (CPU1) had a softirq running, 100%, and many frames were dropped

Just a hint, I use 'ethtool -S fiber1' to see how the packets gets 
distributed across the rx and tx queues.



> CLONE_SKB="clone_skb 15"

Be careful with to high clone, as my experience is it will send a burst of 
clone_skb packets before the packet gets randomized again.


> pgset "dst_min 192.168.0.2"
> pgset "dst_max 192.168.0.250"
> pgset "src_min 192.168.0.1"
> pgset "src_max 192.168.0.1"
> pgset "dst_mac  00:1b:21:4a:fe:55"

To get a packets randomized across RX queues, I used:

     echo "- Random UDP source port min:$min - max:$max"
     pgset "flag UDPSRC_RND"
     pgset "udp_src_min $min"
     pgset "udp_src_max $max"

Ahh.. I think you are missing:

  pgset "flag IPDST_RND"


Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
