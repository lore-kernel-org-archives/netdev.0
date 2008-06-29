From: Sven Wegener <sven.wegener@stealer.net>
Subject: [PATCHv2] ipvs: Cleanup sync daemon code
Date: Sun, 29 Jun 2008 19:32:41 +0200
Message-ID: <1214760766-1526-1-git-send-email-sven.wegener@stealer.net>
Cc: netdev@vger.kernel.org
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.stealer.net ([88.198.224.204]:55451 "EHLO
	smtp1.stealer.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755462AbYF2SFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2008 14:05:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's been a while since my last post of this patch series, but here we go gain.

Changes since last post:
- Dropped the master daemon sleep change for now, that needs some more work.
- Splitted up the patch into a couple of logical chunks.

The patches are

Sven Wegener (5):
      ipvs: Initialize mcast addr at compile time
      ipvs: Use ERR_PTR for returning errors from make_receive_sock() and make_send_sock()
      ipvs: Use kthread_run() instead of doing a double-fork via kernel_thread()
      ipvs: Put backup thread on mcast socket wait queue
      ipvs: Use schedule_timeout_interruptible() instead of msleep_interruptible()

The overall difstat looks like

 ip_vs_sync.c |  431 +++++++++++++++++++++++------------------------------------
  1 file changed, 172 insertions(+), 259 deletions(-)

The patches are based on v2.6.26-rc8. If someone wants to pull them, that can
be done from

git://git.stealer.net/linux-2.6.git stealer/ipvs/sync-daemon-cleanup

Sven
