From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] netif_rx: receive path optimization
Date: Wed, 30 Mar 2005 15:53:26 -0800
Message-ID: <20050330155326.17cd6042@dxpl.pdx.osdl.net>
References: <20050330132815.605c17d0@dxpl.pdx.osdl.net>
	<1112219848.1078.93.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1112219848.1078.93.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 30 Mar 2005 16:57:29 -0500
jamal <hadi@cyberus.ca> wrote:

> On Wed, 2005-03-30 at 16:28, Stephen Hemminger wrote:
> > This patch cleans up the netif_rx and related code in the network
> > receive core.
> > 
> >      - Eliminate vestiges of fastroute.
> >        The leftover statistics no longer needed.
> > 
> >      - Get rid of high/med/low threshold return from netif_rx.
> >        Drivers rarely check return value of netif_rx, and those
> >        that do can handle the DROP vs SUCCESS return
> > 
> 
> Please leave this feature in. Drivers that used it have moved on to a
> better life under NAPI; however, it is still useful for anyone who wants
> to take  heed of congestion. And infact it is highly advisable for
> anyone not using NAPI to using it.
> In other words: the work should be to convert users of netif_rx and not
> to get rid of this feature.

How about percentages instead of multiple sysctl values? Or some relationship
of max_queue and max_backlog.
	success  qlen < max_backlog
	low 	 qlen > max_backlog
	medium   qlen > max_queue/2
	high	 qlen > max_queue - max_backlog
	drop	 qlen > max_queue

Also, RAND_LIE (dead code) is
kind of confusing because I expected it to be a receive version of Random
Drop, but it really just lies back to the caller (and keeps the packet).
