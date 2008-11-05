From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Network performance forwarding tests on RT
Date: Wed, 5 Nov 2008 11:52:05 -0800
Message-ID: <20081105115205.14c5282f@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-rt-users@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45646 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752904AbYKETwS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2008 14:52:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As an experiment, I rebuilt a version of Vyatta using 2.6.26-rt11 kernel.
This required some fixes to unionfs and aufs which I'll send to anyone who wants.

The performance of the RT PREEMPT kernel is worse than non-PREEMPT kernel.

Running RFC2544, frame loss test we the loss rate is worse on RT than non RT.
Ideally, there would be no loss, but on this platform, the best we have
seen is 70% loss at 64 bytes.


Size	2.6.26		2.6.26-rt11
64	80.5%		99%
128	67		99
256	43		92
512	0		54
1024	0		3
1280	0		0
1518	0		0

More importantly, with RT PREEMPT, the driver gets stuck and times out
under heavy load (see 99% loss above). It appears the change to network
scheduling related to NAPI doesn't work well under load.

I wouldn't recommend RT PREEMPT for heavy network loads.

Hardware: Celeron 430 @ 1.80GHz  Intel dual-port 82546GB NIC

Config:

CONFIG_NR_CPUS=8
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT_DESKTOP is not set
CONFIG_PREEMPT_RT=y
CONFIG_PREEMPT=y
CONFIG_PREEMPT_SOFTIRQS=y
CONFIG_PREEMPT_HARDIRQS=y
CONFIG_PREEMPT_RCU=y
CONFIG_PREEMPT_RCU_BOOST=y
