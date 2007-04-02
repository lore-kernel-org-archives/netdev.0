From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: intermittant petabyte usage reported with broadcom nic
Date: Mon, 2 Apr 2007 00:13:00 -0700
Message-ID: <20070402001300.3b66007d.akpm@linux-foundation.org>
References: <20070402014319.GA8345@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: CaT <cat@zip.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:42217 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753359AbXDBHNE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Apr 2007 03:13:04 -0400
In-Reply-To: <20070402014319.GA8345@zip.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2 Apr 2007 11:43:19 +1000 CaT <cat@zip.com.au> wrote:

> I take minute by minute snapshots of network traffic by sampling
> /proc/net/dev and most of the time everything works fine. Occasionally
> though I get petabyte byte traffic and corresponding packet traffic.

How frequently?

Are you able to provide some actual numbers (expected and actual values),
so we can look at the bit patterns?

> This happens on an AMD64, dual core smp box with Broadcom NetXtreme II
> nics.

What driver drivers that?  b44.c?

> The issue happens with both nics but at different times. The same
> sampling code runs on p4 boxes with ht on and e1000 nics without issues
> so I don't believe it's an issue with my code (famous last words :)
> which just does an re to extract the data on a per-line basis and prints
> it out. Still, I'll be adding code to log any big readings and hopefully
> it'll happen again sooner rather then later.
> 
> There is no preemption involved and the kernel is a monolythic build of
> 2.6.19.[12] (there are two servers).

We do perform racy 64-bit updates of some of the stats counters.  But
that'll only affect 32-bit kernels and I'm assuming you're running a 64-bit
kernel on that AMD64 box (are you?)

Plus it's odd that both the byte-counters and the packet-counters go wonky
at the same time.

