From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-2.6.26] netlink: make socket filters work on netlink
Date: Wed, 2 Apr 2008 16:05:38 +0200
Message-ID: <20080402140538.GC20815@postel.suug.ch>
References: <20080331123311.64e4ca37@extreme> <47F13E43.2040404@trash.net> <20080331.130757.199769025.davem@davemloft.net> <47F1467F.2080407@trash.net> <1207000143.4424.167.camel@localhost> <47F22211.5080100@trash.net> <1207058646.4424.218.camel@localhost> <47F35933.5080305@trash.net> <1207136533.4451.132.camel@localhost> <47F37702.1080702@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, David Miller <davem@davemloft.net>,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:50208 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752846AbYDBOFS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2008 10:05:18 -0400
Content-Disposition: inline
In-Reply-To: <47F37702.1080702@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Patrick McHardy <kaber@trash.net> 2008-04-02 14:07
> jamal wrote:
> >a) that the pid belonged to the source - and 0 means "kernel". 

I'm using the term netlink port for now, it avoids the confusion
and makes it clear what nlmsg_pid really is.

> Yes, for ioctl it can't carry anything but zero because it
> should contains the netlink socket pid, not the process ID,
> which obviously doesn't exist in that case.

I like the idea of a magic number although I would define it as
originator is userspace but we do not know the netlink port number.

> >b) The pid could also be some negative number (even in qdisc_notify) if
> >you have multiple netlink sockets in one process (resolvable if you
> >getname())
> 
> True, but that doesn't really matter. You also can't assume that
> a positive number matches the process ID.

The netlink port is a unsigned 32 bit value, period.

> >c) what happens when processid goes to > 32-bit?
> 
> Wouldn't be a problem, its the netlink socket pids, which are 32
> bit no matter what.

Also the process id is not even 32 bit so far which gives libnl the
ability to generate unique netlink ports based on the real process id
plus some iterator value. Applications using libnl which do not
generate the port number themselves could theoretiaclly resolve the real
process id back even if there are multiple sockets per application.

> In my opinion we should try to set nlmsg_pid properly since thats
> whats defined as unique identifier for netlink sockets.

Agreed.
