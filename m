From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: possible NAPI improvements to reduce interrupt rates for low traffic rates
Date: 08 Sep 2007 18:32:59 +0200
Message-ID: <p737in19kxw.fsf@bingen.suse.de>
References: <200709061416.l86EG0Vb017675@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, davem@davemloft.net,
	jeff@garzik.org, mandeep.baines@gmail.com, ossthema@de.ibm.com
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:47713 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753355AbXIHQdC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Sep 2007 12:33:02 -0400
In-Reply-To: <200709061416.l86EG0Vb017675@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Chapman <jchapman@katalix.com> writes:
> 
> Clearly, keeping a device in polled mode for 1-2 jiffies 

1-2 jiffies can be a long time on a HZ=100 kernel (20ms). A fast CPU
could do a lot of loops in this time, which would be waste of power
and CPU time.

On some platforms the precise timers (like ktime_get()) can be slow,
but often they are fast.  It might make sense to use a shorter
constant time wait on those with fast timers at least. Right now this
cannot be known by portable code, but there was a proposal some time
ago to export some global estimate to tell how fast
ktime_get().et.al. are. That could be reviewed.

-Andi
