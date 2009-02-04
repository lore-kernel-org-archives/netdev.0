From: Patrick Ohly <patrick.ohly@intel.com>
Subject: clock synchronization utility code
Date: Wed,  4 Feb 2009 14:01:55 +0100
Message-ID: <1233752517-30010-1-git-send-email-patrick.ohly@intel.com>
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	John Stultz <johnstul@us.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:48688 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759467AbZBDNCB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2009 08:02:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello!

These two patches are part of the larger patch series which adds
support for a hardware assisted implementation of the Precision Time
Protocol (PTP, IEEE 1588). They apply to net-next-2.6 as of a few days
ago, which itself was recently merged with v2.6.29-rc2.

It seems that we have reached a consensus how the networking
infrastructure needs to be changed; I have already adapted the patch
series accordingly. See the mail thread "hardware time stamping with
optional structs in data area" for details:
   http://kerneltrap.org/mailarchive/linux-netdev/2009/1/21/4781774

We are less sure about these two patches because they are outside of
the network subsystem. The clocksource patch was already reviewed by
John and hasn't been changed since then. The second patch hasn't been
reviewed.

Both patches add code which is not called and has no effect unless a
driver developer decides to use this utility code. The larger patch
series contains patches to the igb driver which invoke the code. This
is how I tested it on 32 and 64 bit x86.

How should we proceed with these patches? David and I agree that it
would make sense to include them via the net-next-2.6 together with
the rest of the patch series. That way we ensure that no dead code
without users ends up in the kernel. Please let us know how we can
coordinate this so that friction between the subsystem trees is
minimized.

Diff summary:
 include/linux/clocksource.h |  101 ++++++++++++++++++++++
 include/linux/clocksync.h   |  102 ++++++++++++++++++++++
 kernel/time/Makefile        |    2 
 kernel/time/clocksource.c   |   77 ++++++++++++++++-
 kernel/time/clocksync.c     |  198 +++++++++++++++++++++++++++++++++++++++++++-
 5 files changed, 477 insertions(+), 3 deletions(-)

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.
