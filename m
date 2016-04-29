From: Deepa Dinamani <deepa.kernel@gmail.com>
Subject: [PATCH 0/3] Use timespec64 for select like timeouts
Date: Fri, 29 Apr 2016 09:39:46 -0700
Message-ID: <1461947989-21926-1-git-send-email-deepa.kernel@gmail.com>
Cc: arnd@arndb.de, y2038@lists.linaro.org,
	linux-fsdevel@vger.kernel.org,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:33159 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751954AbcD2Qkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 12:40:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The series is part of y2038 changes.

This changes a few syscalls that have common functions to use
struct timespec64 instead of struct timespec.

This does not include changes to system call uapi interfaces.
Those will be in a different series.

Thanks to Arnd Bergmann for comments on the patches.

Deepa Dinamani (3):
  time: Add missing implementation for timespec64_add_safe()
  fs: poll/select/recvmmsg: use timespec64 for timeout events
  time: Remove timespec_add_safe()

 fs/eventpoll.c         | 12 ++++-----
 fs/select.c            | 67 ++++++++++++++++++++++++++++----------------------
 include/linux/poll.h   | 11 +++++----
 include/linux/time64.h | 17 ++++++-------
 kernel/time/time.c     | 21 ++++++++++++++++
 net/socket.c           |  8 +++---
 6 files changed, 82 insertions(+), 54 deletions(-)

-- 
1.9.1

Cc: John Stultz <john.stultz@linaro.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
