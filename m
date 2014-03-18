From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 00/12] can: c_can: Fix a series of serious bugs and improve
 the performance
Date: Tue, 18 Mar 2014 17:19:07 -0000
Message-ID: <20140318171007.528610837@linutronix.de>
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Markus Pargmann <mpa@pengutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

First of all, I'm really grumpy as hell.

This is the worst driver I looked at in the last 10 years. And that's
an achievement.

The driver is full of serious bugs:

    - Two HW init routines are not spec compliant.

    - Completely defective message buffer handling in several ways
      That leads to interrupt storms and complete lockups.

    - Complete lack of SMP awareness

What's amazing is that people "optimize" and "fix" the driver over and
over, but nobody bothered to understand the manual and repair the code
for real.

The series fixes _ALL_ bugs which I found so far, but I'm sure there
are more issues burried in that unreadable mess. I'm just not able to
trigger them.

The last few patches add real performance improvements by removing a
gazillion of pointless hardware operations.

Thanks,

	tglx

--------------->

 c_can.c          |  311 ++++++++++++++++++++++++++++++-------------------------
 c_can.h          |   29 +++++
 c_can_platform.c |   48 ++++++--
 3 files changed, 241 insertions(+), 147 deletions(-)
