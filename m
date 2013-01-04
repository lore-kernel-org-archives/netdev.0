From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] softirq: reduce latencies
Date: Fri, 04 Jan 2013 09:00:24 -0800
Message-ID: <1357318824.1678.1678.camel@edumazet-glaptop>
References: <1357216132.21409.24107.camel@edumazet-glaptop>
	 <1357250880.2685.29.camel@bwh-desktop.uk.solarflarecom.com>
	 <1357252816.21409.26384.camel@edumazet-glaptop>
	 <1357285780.21409.28416.camel@edumazet-glaptop>
	 <1357287351.5452.44.camel@joe-AO722>
	 <1357287786.1678.87.camel@edumazet-glaptop>
	 <1357290721.5452.55.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f43.google.com ([209.85.210.43]:53901 "EHLO
	mail-da0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755119Ab3ADRA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 12:00:28 -0500
In-Reply-To: <1357290721.5452.55.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-01-04 at 01:12 -0800, Joe Perches wrote:
> On Fri, 2013-01-04 at 00:23 -0800, Eric Dumazet wrote:
> > On Fri, 2013-01-04 at 00:15 -0800, Joe Perches wrote:
> > > Perhaps MAX_SOFTIRQ_TIME should be
> > > #define MAX_SOFTIRQ_TIME msecs_to_jiffies(2)
> > > though it would be nicer if it were a compile time constant.
> > 
> > If you send a patch to convert msecs_to_jiffies() to an inline function
> > when HZ = 1000, I will gladly use it instead of (2*HZ/1000)
> > 
> > Right now, max(1, msecs_to_jiffies(2)) uses way too many instructions,
> > while it should be the constant 2, known at compile time.
> 
> Something like this might work.
> 
> This is incomplete, it just does msecs_to_jiffies,
> and it should convert usecs_to_jiffies and the
> jiffies_to_<foo> types too.
> 
> Maybe it's worthwhile.
> 
> It does reduce object size by 16 bytes per call site
> (x86-32) when the argument is a constant. There are
> about 800 of these jiffies conversions in kernel sources.
> 
> What do you think?
> 

I think this is something to discuss in another thread, and definitely
worth to do, at least for msecs_to_jiffies()

We have many HZ references everywhere that could be cleaned up using
this.
