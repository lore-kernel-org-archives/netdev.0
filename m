From: Tejun Heo <tj@kernel.org>
Subject: [PATCHSET REPOST] printk, netconsole: implement extended console support
Date: Thu, 14 May 2015 12:06:19 -0400
Message-ID: <1431619586-29187-1-git-send-email-tj@kernel.org>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the combined repost of the following two patches with only
minor updates - warning message and comments added as suggested by
Andrew.  I think it'd be best to route the changes through -mm.

[1] [PATCHSET] printk: implement extended console support
[2] [PATCHSET v3] netconsole: implement extended console support

The netconsole part has been reviewed by David[3].

This patchset updates netconsole so that it can emit messages with the
same header as used in /dev/kmsg which gives neconsole receiver full
log information which enables things like structured logging and
detection of lost messages.

Please see the head messages of the original postings for more
detailed info.

 0001-printk-guard-the-amount-written-per-line-by-devkmsg_.patch
 0002-printk-factor-out-message-formatting-from-devkmsg_re.patch
 0003-printk-implement-support-for-extended-console-driver.patch
 0004-netconsole-remove-unnecessary-netconsole_target_get-.patch
 0005-netconsole-make-netconsole_target-enabled-a-bool.patch
 0006-netconsole-make-all-dynamic-netconsoles-share-a-mute.patch
 0007-netconsole-implement-extended-console-support.patch

0001-0003 implement extended console support in printk.

0004-0007 update netconsole to support extended console.

The patchset is also available in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/misc.git review-netconsole-ext-console

diffstat follows.  Thanks.

 Documentation/ABI/testing/dev-kmsg      |    9 +
 Documentation/networking/netconsole.txt |   35 +++++
 drivers/net/netconsole.c                |  169 ++++++++++++++++++++++---
 include/linux/console.h                 |    1 
 include/linux/printk.h                  |    2 
 kernel/printk/printk.c                  |  214 +++++++++++++++++++++-----------
 6 files changed, 341 insertions(+), 89 deletions(-)

--
tejun

[1] http://lkml.kernel.org/g/1430318704-32374-1-git-send-email-tj@kernel.org
[2] http://lkml.kernel.org/g/1431362494-9874-1-git-send-email-tj@kernel.org
[3] http://lkml.kernel.org/g/20150514.003917.1450039994643712704.davem@davemloft.net
