From: David Miller <davem@davemloft.net>
Subject: Re: Using netconsole for debugging suspend/resume
Date: Thu, 08 Jun 2006 22:23:52 -0700 (PDT)
Message-ID: <20060608.222352.59657133.davem@davemloft.net>
References: <20060608210702.GD24227@waste.org>
	<4488D4DE.3000100@goop.org>
	<4489038C.3050901@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeremy@goop.org, mpm@selenic.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:52143
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965208AbWFIFYj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 01:24:39 -0400
To: auke-jan.h.kok@intel.com
In-Reply-To: <4489038C.3050901@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Auke Kok <auke-jan.h.kok@intel.com>
Date: Thu, 08 Jun 2006 22:13:48 -0700

> netconsole should retry. There is no timeout programmed here since that might
> lose important information, and you rather want netconsole to survive an odd
> unplugged cable then to lose vital debugging information when the system is
> busy for instance. (losing link will cause the interface to be down and thus
> the queue to be stopped)

I completely disagree that netpoll should loop when the ethernet
cable is plugged out.  This stops the entire system.  What if this
is one of my main web servers and I have other links on the machine
for redundancy and load balancing?  Just because some careless
sysop knocks one of the cables out, my system just freezes up and
stops?

What if I'm on a remote serial console, how long should I scratch
my head wondering why the whole machine is frozen up before I "figure
out" that the ethernet cable being out has made my system unusable
because netpoll is just looping on the thing forever?

That's an extremely poor quality of implementation if you ask me.

Netpoll is _BEST_ _EFFORT_, end of story.  It by definition can only
offer that level of service because it does locking in circumstances
where such locking might be illegal or even impossible.  So it has to
try, but if it can't get the resources it needs, it must stop trying
and abort the logging.
