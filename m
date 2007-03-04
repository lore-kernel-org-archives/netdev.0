From: Patrick McHardy <kaber@trash.net>
Subject: [RFC NET_SCHED 00/03]: ktime + nano-second clock resolution for packet schedulers
Date: Sun,  4 Mar 2007 20:05:30 +0100 (MET)
Message-ID: <20070304190439.21142.66736.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>, shemminger@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61544 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751817AbXCDTFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2007 14:05:31 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches convert the GETTIMEOFDAY packet scheduler clock source to
ktime (based on Stephen's patch) and add support for using nano-second
clock resolution. I chose a scalar time representation within the packet
schedulers instead of ktime_t since it minimizes the ktime_to_ns() calls
in most cases, it allows to clean up pkt_sched.h quite a bit and HFSC
needs it anyway.

Unlike my previous attempt at this, these patches keep old iproute
versions working with nano-second resolution with the exception of HFSC.
I'm not sure what to do about HFSC yet, so just RFC for now.


 include/linux/jiffies.h |    2 
 include/net/pkt_sched.h |  141 ++++++++++--------------------------------------
 kernel/hrtimer.c        |    1 
 kernel/time.c           |   26 ++++++++
 net/sched/Kconfig       |   17 +++++
 net/sched/sch_api.c     |   11 ++-
 net/sched/sch_hfsc.c    |   37 +++++-------
 7 files changed, 100 insertions(+), 135 deletions(-)

Patrick McHardy:
      [TIME]: Add jiffies_to_nsecs/nsecs_to_jiffies
      [NET_SCHED]: Replace gettimeofday clocksource by ktime
      [NET_SCHED]: Add support for nano-second clock resolution
