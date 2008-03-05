From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 0/2][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Wed, 5 Mar 2008 23:20:27 GMT
Message-ID: <200803052320.m25NKRmt003890@quickie.katalix.com>
Cc: jarkao2@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:46258 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755027AbYCEXUd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2008 18:20:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set fixes some locking issues in the pppol2tp driver which
can cause a kernel crash on SMP boxes when hundreds of L2TP sessions
are created/deleted simultaneously (ISP environment).

There are 2 patches:-

   1. use softirq-safe spinlocks and don't take sk_dst_lock in the
      transmit path

   2. fix races in dequeueing skbs from a session's reorder queue.

There are still problems lurking somewhere in the driver that cause
the kernel to hang but this only happens under certain stress test
conditions. The fixes provided in this patch set fix fundamental
locking issues in the driver which have caused an oops in more than
one setup, hence this patch set is being pushed upstream now while we
continue to work on the kernel hang.

Signed-off-by: James Chapman <jchapman@katalix.com>

--

A previous version of this patch set used _irq variants of the lock
functions. A lengthy thread discussing it is archived at
http://marc.info/?l=linux-netdev&m=120272177622133&w=4

If the patches are accepted, can they also be pushed to the stable
2.6.23 and 2.6.24 trees?

