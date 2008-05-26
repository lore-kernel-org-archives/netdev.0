From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: POHMELFS high performance network filesystem. Cache coherency, transactions, parallels.
Date: Mon, 26 May 2008 11:12:15 +0400
Message-ID: <20080526071210.GC16366@2ka.mipt.ru>
References: <20080525134055.GA30630@2ka.mipt.ru> <483A153F.7000907@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754881AbYEZHMr@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <483A153F.7000907@garzik.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 25, 2008 at 09:41:19PM -0400, Jeff Garzik (jeff@garzik.org) wrote:
> Often you can capture this information in a more scalable manner, by 
> having the clients measure an observable _output_ such as latency, over 
> time.
> 
> Each transaction gives the client new feedback about the server(s) being 
> offline (i.e. timeout), becoming slow, etc.

Server should be able to provide such info because of sudden changes in
environment or administrative tasks. It should not be that many of such
messages, but some info should be broadcasted to connected clients.
Client by itself should also e able to determine if given server is fast
enough of course.
 
> Another potential tool is having the server(s) send an abstract number, 
> from 0-100, indicating their level of desire for new { read | write } 
> transactions.  Let us call this client hint "weight".  Rather than have 
> a bunch of status messages that indicate server load average, or 
> do-not-read state, summarize this information into read_weight and 
> write_weight hints to the client.

I actually meant only single message with status structure, which can
include whatever we decided to put there including such kind of hints.

> With just a few (two?) simple variables, the client is given the ability 
> to automatically balance and scale load across the cluster, work around 
> failing servers, etc.
> 
> Write balancing need not be overly complex...

Yup, some kind of that. I did not yet thought about it in details...

-- 
	Evgeniy Polyakov
