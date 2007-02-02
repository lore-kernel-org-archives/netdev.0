From: Andi Kleen <ak@suse.de>
Subject: Re: "meaningful" spinlock contention when bound to non-intr CPU?
Date: Fri, 2 Feb 2007 20:06:31 +0100
Message-ID: <200702022006.31934.ak@suse.de>
References: <45C242C9.1010601@hp.com> <p731wl8nz5q.fsf@bingen.suse.de> <45C3871F.2030301@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:33991 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422965AbXBBTGh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 14:06:37 -0500
In-Reply-To: <45C3871F.2030301@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> 
> The meta question behind all that would seem to be whether the scheduler 
> should be telling us where to perform the network processing, or should 
> the network processing be telling the scheduler what to do? (eg all my 
> old blathering about IPS vs TOPS in HP-UX...)

That's an unsolved problem.  But past experiments suggest that giving
the scheduler more imperatives than just "use CPUs well" are often net-losses.

I suspect it cannot be completely solved in the general case. 

> Well, yes and no.  If I drop the "burst" and instead have N times more 
> netperf's going, I see the same lock contention situation.  I wasn't 
> expecting to - thinking that if there were then N different processes on 
> each CPU the likelihood of there being a contention on any one socket 
> was low, but it was there just the same.
> 
> That is part of what makes me wonder if there is a race between wakeup 

A race?

> and release of a lock.

You could try with echo 1 > /proc/sys/net/ipv4/tcp_low_latency.
That should change RX locking behaviour significantly.

-Andi
