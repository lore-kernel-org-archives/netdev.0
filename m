From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/4] Introduce and use printk pointer extension %pV
Date: Sun, 27 Jun 2010 04:02:32 -0700
Message-ID: <cover.1277636090.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1302 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754629Ab0F0LCj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jun 2010 07:02:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recursive printk can reduce the total image size of an x86 defconfig about 1% 
by reducing duplicated KERN_<level> strings and centralizing the functions
used by macros in new separate functions.

Joe Perches (4):
  vsprintf: Recursive vsnprintf: Add "%pV", struct va_format
  device.h drivers/base/core.c Convert dev_<level> logging macros to functions
  netdevice.h net/core/dev.c: Convert netdev_<level> logging macros to functions
  netdevice.h: Change netif_<level> macros to call netdev_<level> functions

 drivers/base/core.c       |   64 +++++++++++++++++++++++++
 include/linux/device.h    |  112 ++++++++++++++++++++++++++++++++++----------
 include/linux/kernel.h    |    5 ++
 include/linux/netdevice.h |   56 ++++++++++++----------
 lib/vsprintf.c            |    9 ++++
 net/core/dev.c            |   62 +++++++++++++++++++++++++
 6 files changed, 256 insertions(+), 52 deletions(-)

