From: Patrick McHardy <kaber@trash.net>
Subject: [RFC IPROUTE 00/08]: Time cleanups + nano-second clock resolution support
Date: Sun,  4 Mar 2007 20:14:53 +0100 (MET)
Message-ID: <20070304191402.22838.91224.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>, shemminger@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61720 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411AbXCDTOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2007 14:14:54 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset consists of four parts:

- minor TBF time conversion fix

- consolidation of time calculations: consolidate commonly used expressions
  with the goal of making it easier to audit for integer overflows when
  increasing the internally used clock resolution.
 
- support for detecting the clock resolution used by the kernel and converting
  time values as necessary.

- finally, increase the internally used clock resolution to nano-seconds

These patches have been tested (well, TBF and HFSC) with both old kernels
and patched kernels using nano-second resolution.


 tc/m_estimator.c  |    4 +--
 tc/m_police.c     |    2 -
 tc/q_cbq.c        |   15 +++++++------
 tc/q_hfsc.c       |   18 +++++++--------
 tc/q_htb.c        |    4 +--
 tc/q_netem.c      |   14 +++---------
 tc/q_tbf.c        |   22 +++++++++----------
 tc/tc_cbq.c       |    8 +++----
 tc/tc_core.c      |   61 ++++++++++++++++++++++++++++++++++++++----------------
 tc/tc_core.h      |   13 +++++++----
 tc/tc_estimator.c |    2 -
 tc/tc_red.c       |    2 -
 tc/tc_util.c      |   40 ++++++++++++++++++++++-------------
 tc/tc_util.h      |    7 +++---
 14 files changed, 125 insertions(+), 87 deletions(-)

Patrick McHardy:
      [IPROUTE]: tbf: fix latency printing
      [IPROUTE]: Use tc_calc_xmittime() where appropriate
      [IPROUTE]: Introduce tc_calc_xmitsize and use where appropriate
      [IPROUTE]: Introduce TIME_UNITS_PER_SEC to represent internal clock resolution
      [IPROUTE]: Replace "usec" by "time" in function names
      [IPROUTE]: Add sprint_ticks() function and use in CBQ
      [IPROUTE]: Handle different kernel clock resolutions
      [IPROUTE]: Increase internal clock resolution to nsec
