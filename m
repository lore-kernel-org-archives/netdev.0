From: Amerigo Wang <amwang@redhat.com>
Subject: [PATCH 0/5] notifiers: split notifier.h into subsystem headers
Date: Wed, 22 Jun 2011 14:35:17 +0800
Message-ID: <1308724522-32461-1-git-send-email-amwang@redhat.com>
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	WANG Cong <amwang@redhat.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now we define all kinds of notifiers in notifier.h, this is not
necessary at all, since different subsystems use different
notifiers, they are almost non-related with each other.

This can also save much build time. Suppose I add a new netdevice
event, really I don't have to recompile all the source, just network
related. Without this patch, all the source will be recompiled.

I move the notify events near to their subsystem notifier registers,
so that they can be found more easily.

In case of conflicts, I hope Andrew Morton would take the whole
patchset, rather than different subsystem maintainers take their own.

Signed-off-by: WANG Cong <amwang@redhat.com>

---
 drivers/mmc/core/core.c   |    3 ++
 include/linux/cpu.h       |   33 ++++++++++++++++++
 include/linux/netdevice.h |   36 ++++++++++++++++++--
 include/linux/notifier.h  |   82 +++-----------------------------------------
 include/linux/reboot.h    |    5 +++
 include/linux/suspend.h   |    8 ++++
 include/linux/vt.h        |    7 ++++
 kernel/notifier.c         |   31 -----------------
 kernel/sys.c              |   32 +++++++++++++++++-
 net/rds/page.c            |    1 +
 10 files changed, 127 insertions(+), 111 deletions(-)
