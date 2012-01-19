From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: Netfilter: New target: RLOG
Date: Thu, 19 Jan 2012 10:12:48 +0100
Message-ID: <20120119091248.GA32391@1984>
References: <1326926610-17830-1-git-send-email-rw@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, rostedt@goodmis.org
To: Richard Weinberger <rw@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47767 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755574Ab2ASJMx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 04:12:53 -0500
Content-Disposition: inline
In-Reply-To: <1326926610-17830-1-git-send-email-rw@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Richard,

On Wed, Jan 18, 2012 at 11:43:25PM +0100, Richard Weinberger wrote:
> RLOG is a new log target, it works like LOG with the exception that it writes to ring buffers.
> It makes use of Steven Rostedt's ring_buffer subsystem. 
> I've used Steve's ring buffer because it allows concurrent writes. IOW it's very fast.
> For more details see: Documentation/trace/ring-buffer-design.txt.
> 
> Each ring buffer is represented as a pipe-like file in /proc/net/netfilter/xt_RLOG/.
> You can read from it with and program you like (cat, syslog, etc...).
> The default size is 1MiB. With this size it can store approximately 5000 messages.
> 
> - Why not LOG?
> I like the LOG target a lot but I really hat it when it floods my kernel syslog.
> dmesg becomes useless.
> Writing all log messages to a file using syslogd also not always the best solution.
> Most of the time my firewall logs just waste disk space.
> 
> Compared with Steve's ring_buffer, the kernel syslog is rather slow.
> Especially when the firewall logs very much syslog becomes a bottleneck.
> As we all know printk() is not fast.
> 
> - Why not ULOG/NFLOG?
> Because it cannot replace LOG.
> Details like PHYSIN and PHYSOUT are not available form the packet headers.
> Also on many Linux systems ulogd is not available/supported.  

We only include physin and phyout if netfilter bridge is enabled. I
may be missing anything but, why can these be useful if bridging is not
enabled?

> - Why RLOG?
> Using RLOG you can have many ring buffers with all kind of logs.
> If your firewall goes nuts you don't have to mess you rule-set with adding
> new LOG rules to find out what's going on.
> Just install a few RLOG rules with small buffer sized and read them if you don't
> know what's going on.
> If you make you firewall rule-set per default verbose using LOG or NFLOG it will 
> generate lot's of useless messages which you'll never ever read.
> With RLOG you can bypass this problem.
> On my firewall I record only useful data to the disk. Everything else goes into RLOG.
> If your firewall is really busy and you want to log nearly everything, c
> reate a big ring buffer and read from is using your favorite userspace tool.
> In case the buffer fills faster than the userspace consumes it, RLOG will warn you.
> I'd also possible to resize the buffer.

I still think this can be useful.

But, why don't you add this to the LOG target as an extension instead
of yet another target?
