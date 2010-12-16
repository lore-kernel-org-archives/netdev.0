From: Joe Perches <joe@perches.com>
Subject: Re: pktgen IP address stepping
Date: Thu, 16 Dec 2010 13:22:59 -0800
Message-ID: <1292534579.29894.77.camel@Joe-Laptop>
References: <20101216172800.GA8404@spritelink.se>
	 <1292522532.29894.33.camel@Joe-Laptop>
	 <20101216211153.GA8658@spritelink.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Kristian Larsson <kristian@spritelink.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2729 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753305Ab0LPVXB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Dec 2010 16:23:01 -0500
In-Reply-To: <20101216211153.GA8658@spritelink.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-12-16 at 22:11 +0100, Kristian Larsson wrote:
> On Thu, Dec 16, 2010 at 10:02:12AM -0800, Joe Perches wrote:
> > pr_<foo> calls are already prefixed with pktgen via pr_fmt,
> > you don't need to add it to the format string.
> I can see at least two different cases of debug statements;
>     if (debug)
>         pr_info("Delay set at: %llu ns\n", pkt_dev->delay);
>     if (debug)
>         printk(KERN_DEBUG "pktgen: dst_min set to: %s\n",
>                pkt_dev->dst_min);
> what's the reasoning behind using one or the other?

pr_info(fmt, ...)	emits at KERN_INFO level and uses pr_fmt(fmt)
printk(KERN_DEBUG	emits at KERN_DEBUG level and doesn't use pr_fmt
pr_debug(fmt, ...)	does use pr_fmt and is optionally compiled.

I can't say why the author decided to use a info level output
for the delay set message.  Maybe that person doesn't like to see
KERN_DEBUG messages.

cheers, Joe

