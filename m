From: Palmer Dabbelt <palmer@dabbelt.com>
Subject: [PATCH 06/13] Hide ep_take_care_of_epollwakeup() behind #ifdef __KERNEL__
Date: Wed,  9 Sep 2015 14:08:15 -0700
Message-ID: <1441832902-28993-7-git-send-email-palmer@dabbelt.com>
References: <2644177.lVCYzIBfPW@wuerfel>
 <1441832902-28993-1-git-send-email-palmer@dabbelt.com>
Cc: 3chas3@gmail.com
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34632 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754174AbbIIVIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 17:08:52 -0400
Received: by padhy16 with SMTP id hy16so20835186pad.1
        for <netdev@vger.kernel.org>; Wed, 09 Sep 2015 14:08:51 -0700 (PDT)
Cc: hpa@zytor.com
Cc: mingo@redhat.com
Cc: plagnioj@jcrosoft.com
Cc: jikos@kernel.org
Cc: linux-api@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-atm-general@lists.sourceforge.net
Cc: linux-fbdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: tglx@linutronix.de
Cc: tomi.valkeinen@ti.com
Cc: x86@kernel.org
Cc: Palmer Dabbelt <palmer@dabbelt.com>
In-Reply-To: <1441832902-28993-1-git-send-email-palmer@dabbelt.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This doesn't make any sense to expose to userspace.

Signed-off-by: Palmer Dabbelt <palmer@dabbelt.com>
Reviewed-by: Andrew Waterman <waterman@eecs.berkeley.edu>
Reviewed-by: Albert Ou <aou@eecs.berkeley.edu>
---
 include/uapi/linux/eventpoll.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/uapi/linux/eventpoll.h b/include/uapi/linux/eventpoll.h
index bc81fb2e1f0e..290426bfb0aa 100644
--- a/include/uapi/linux/eventpoll.h
+++ b/include/uapi/linux/eventpoll.h
@@ -61,6 +61,7 @@ struct epoll_event {
 	__u64 data;
 } EPOLL_PACKED;
 
+#ifdef __KERNEL__
 #ifdef CONFIG_PM_SLEEP
 static inline void ep_take_care_of_epollwakeup(struct epoll_event *epev)
 {
@@ -73,4 +74,6 @@ static inline void ep_take_care_of_epollwakeup(struct epoll_event *epev)
 	epev->events &= ~EPOLLWAKEUP;
 }
 #endif
+#endif /*__KERNEL__*/
+
 #endif /* _UAPI_LINUX_EVENTPOLL_H */
-- 
2.4.6
