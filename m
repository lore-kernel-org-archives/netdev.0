From: David Miller <davem@davemloft.net>
Subject: Re: [RFC, PATCH 0/7] net, compat_ioctl: move handlers to
 net/socket.c
Date: Fri, 06 Nov 2009 20:47:53 -0800 (PST)
Message-ID: <20091106.204753.223665411.davem@davemloft.net>
References: <1257530949-9695-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, hch@lst.de, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42680
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760071AbZKGEr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 23:47:27 -0500
In-Reply-To: <1257530949-9695-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri,  6 Nov 2009 19:09:02 +0100

> This cleans up some of the socket ioctl handling by moving it
> from fs/compat_ioctl.c to net/socket.c. The code is still untested,
> so this is an RFC for now. If you're happy with it, I'll do some
> testing to see if everything still works.
> 
> This series is a prerequisite for cleaning up the rest of
> compat_ioctl.c, saving some 30kb of kernel memory in the end.
> 
> The first four patches are probably worthwhile independently,
> because they fix some bugs in compat_ioctl handling.
> There is some obvious conflict with the ATM patch I sent
> independently today. That one should probably be worked out
> first.

This looks great, all applied.  Please make the fixups recommended
to you in the feedback as followon patches.

Also, I added the following cure after your patch series:

net: compat: No need to define IFHWADDRLEN and IFNAMSIZ twice.

It's defined colloqually in linux/if.h and linux/compat.h
includes that.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/compat.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/include/linux/compat.h b/include/linux/compat.h
index 8311d2e..224c7a8 100644
--- a/include/linux/compat.h
+++ b/include/linux/compat.h
@@ -166,8 +166,6 @@ struct compat_ifmap {
 };
 
 struct compat_ifreq {
-#define IFHWADDRLEN     6
-#define IFNAMSIZ        16
         union {
                 char    ifrn_name[IFNAMSIZ];            /* if name, e.g. "en0" */
         } ifr_ifrn;
-- 
1.6.5.2

