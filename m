From: Mike Galbraith <efault@gmx.de>
Subject: net/sched: latent livelock in dev_deactivate_many() due to yield()
 usage
Date: Sun, 02 Apr 2017 06:28:41 +0200
Message-ID: <1491107321.13631.33.camel@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        Peter Zijlstra <peterz@infradead.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:61144 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750768AbdDBE3N (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 2 Apr 2017 00:29:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings network wizards,

Quoting kernel/sched/core.c:
/**
 * yield - yield the current processor to other threads.
 *
 * Do not ever use this function, there's a 99% chance you're doing it wrong.
 *
 * The scheduler is at all times free to pick the calling task as the most
 * eligible task to run, if removing the yield() call from your code breaks
 * it, its already broken.
 *
 * Typical broken usage is:
 *
 * while (!event)
 *	yield();
 *
 * where one assumes that yield() will let 'the other' process run that will
 * make event true. If the current task is a SCHED_FIFO task that will never
 * happen. Never use yield() as a progress guarantee!!
 *
 * If you want to use yield() to wait for something, use wait_event().
 * If you want to use yield() to be 'nice' for others, use cond_resched().
 * If you still want to use yield(), do not!
 */

Livelock can be triggered by setting kworkers to SCHED_FIFO, then
suspend/resume.. you come back from sleepy-land with a spinning
kworker.  For whatever reason, I can only do that with an enterprise
like config, my standard config refuses to play, but no matter, it's
"Typical broken usage".

(yield() should be rendered dead)

	-Mike
