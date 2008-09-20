From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/2]: Remote softirq invocation infrastructure.
Date: Fri, 19 Sep 2008 23:48:24 -0700 (PDT)
Message-ID: <20080919.234824.223177211.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jens.axboe@oracle.com,
	steffen.klassert@secunet.com
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35475
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750891AbYITGsh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 02:48:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jens Axboe has written some hacks for the block layer that allow
queueing softirq work to remote cpus.  In the context of the block
layer he used this facility to trigger the softirq block I/O
completion on the same cpu where the I/O was submitted.

I want to make use of a similar facility for the networking, so we
should make this thing generic.

It depends upon the generic SMP call function infrastructure, which
Jens wrote specifically to do these remote softirq hacks.

For each softirq there is a per-cpu list head which is where the work
is queued up.

If the platform doesn't support the generic SMP call function bits,
the work is queued onto the local cpu.

The first patch adds a NR_SOFTIRQS so that we can size these arrays
by the actual number of softirqs instead of the magic number "32"
which is what is used now.

The second patch adds the infrastructure and provides intefaces to
invoke softirqs on remove cpus.

Jen's, as stated, has block layer uses for this.  I intend to use this
for receive side flow seperation on non-multiqueue network cards.  And
Steffen Klassert has a set of IPSEC parallelization changes that can
very likely make use of this.

These patches are against current 2.6.27-rcX

I would suggest that if nobody has any problems with this, we put it
into a GIT tree on kernel.org and any subsystem that wants to use it
can just pull that tree into their GIT tree.  This way, it doesn't
matter which tree Linus pulls in first, he'll get this stuff properly
regardless of ordering.
