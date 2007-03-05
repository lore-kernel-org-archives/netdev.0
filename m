From: David Miller <davem@davemloft.net>
Subject: Re: [RFC NET_SCHED 00/03]: ktime + nano-second clock resolution
 for packet schedulers
Date: Sun, 04 Mar 2007 16:25:57 -0800 (PST)
Message-ID: <20070304.162557.112625456.davem@davemloft.net>
References: <20070304190439.21142.66736.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58124
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752563AbXCEAZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2007 19:25:58 -0500
In-Reply-To: <20070304190439.21142.66736.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Sun,  4 Mar 2007 20:05:30 +0100 (MET)

> These patches convert the GETTIMEOFDAY packet scheduler clock source to
> ktime (based on Stephen's patch) and add support for using nano-second
> clock resolution. I chose a scalar time representation within the packet
> schedulers instead of ktime_t since it minimizes the ktime_to_ns() calls
> in most cases, it allows to clean up pkt_sched.h quite a bit and HFSC
> needs it anyway.
> 
> Unlike my previous attempt at this, these patches keep old iproute
> versions working with nano-second resolution with the exception of HFSC.
> I'm not sure what to do about HFSC yet, so just RFC for now.

This looks great to me.

Frankly, I think now that we have ktime and all of the proper generic
infrastructure to do this stuff properly, I think we should just use
ktime for the packet scheduler across the board and just delete all of
that old by-hand timekeeping selection crap from pkt_sched.h
