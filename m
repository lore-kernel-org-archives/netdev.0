From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] netif_rx: receive path optimization
Date: 30 Mar 2005 16:57:29 -0500
Message-ID: <1112219848.1078.93.camel@jzny.localdomain>
References: <20050330132815.605c17d0@dxpl.pdx.osdl.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050330132815.605c17d0@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-03-30 at 16:28, Stephen Hemminger wrote:
> This patch cleans up the netif_rx and related code in the network
> receive core.
> 
>      - Eliminate vestiges of fastroute.
>        The leftover statistics no longer needed.
> 
>      - Get rid of high/med/low threshold return from netif_rx.
>        Drivers rarely check return value of netif_rx, and those
>        that do can handle the DROP vs SUCCESS return
> 

Please leave this feature in. Drivers that used it have moved on to a
better life under NAPI; however, it is still useful for anyone who wants
to take  heed of congestion. And infact it is highly advisable for
anyone not using NAPI to using it.
In other words: the work should be to convert users of netif_rx and not
to get rid of this feature.

>      - Remove dead code for RAND_LINE and OFFLINE_SAMPLE
> 

OFLINE SAMPLE can go. The other refer to my comments above.

>      - Get rid of weight_p since setting sysctl has no effect.
>        Increase default weight of netif_rx path because it can receive
>        packets from multiple devices and loopback.
> 

Same here.

>      - Separate out max packets per softirq vs. max queued packets.
>        Today, netdev_max_burst is used for both. Add new parameter
>        that is for the per-cpu max queued packets.
> 
>      - Increase queue defaults to meet modern CPU speeds.
>        Make max_backlog be about 1ms, and max_queue be about 10ms
> 

kind of hard to compute what 1 or 10 ms in packet count. But probably
justfied to make the default larger. 

>      - Switch to pure drop tail when queue fills.
>        Better for TCP performance under load to drop a few packets
>        then go into full discard mode.
> 

Like discussed in that thread with person who enhanced the SACK queue
traversal that for a serious use a TCP user really oughta migrate to a
NAPI driver. 

cheers,
jamal
