From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next] doc: fix the compile fix of txtimestamp.c
Date: Sat, 10 Jan 2015 12:08:18 -0500
Message-ID: <1420909698-25025-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
	vlee@twopensource.com, carlos@redhat.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f48.google.com ([209.85.213.48]:33695 "EHLO
	mail-yh0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752686AbbAJRIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2015 12:08:25 -0500
Received: by mail-yh0-f48.google.com with SMTP id i57so6636501yha.7
        for <netdev@vger.kernel.org>; Sat, 10 Jan 2015 09:08:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

A fix to ipv6 structure definitions removed the now superfluous
definition of in6_pktinfo in this file.

But, use of the glibc definition requires defining _GNU_SOURCE
(see also https://sourceware.org/bugzilla/show_bug.cgi?id=6775).

Before this change, the following would fail for me:

  make
  make headers_install
  make M=Documentation/networking/timestamping

with

  Documentation/networking/timestamping/txtimestamp.c: In function '__recv_errmsg_cmsg':
  Documentation/networking/timestamping/txtimestamp.c:205:33: error: dereferencing pointer to incomplete type
  Documentation/networking/timestamping/txtimestamp.c:206:23: error: dereferencing pointer to incomplete type

After this patch compilation succeeded.

Fixes: cd91cc5bdddf ("doc: fix the compile error of txtimestamp.c")
Signed-off-by: Willem de Bruijn <willemb@google.com>

----

Due to the many libc headers included in txtimestamp.c, I was unable
to make it compile cleanly by including the kernel header
(linux/ipv6.h) first, as opposed to using the libc definition.

Btw, should we add the libc-compat.h directly to that file, as opposed
to reading it indirectly through linux/in6.h?

--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -1,6 +1,7 @@
 #ifndef _UAPI_IPV6_H
 #define _UAPI_IPV6_H

+#include <linux/libc-compat.h>
 #include <linux/types.h>
---
 Documentation/networking/timestamping/txtimestamp.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/Documentation/networking/timestamping/txtimestamp.c b/Documentation/networking/timestamping/txtimestamp.c
index 8778e68..05694fe 100644
--- a/Documentation/networking/timestamping/txtimestamp.c
+++ b/Documentation/networking/timestamping/txtimestamp.c
@@ -30,6 +30,8 @@
  * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
  */
 
+#define _GNU_SOURCE
+
 #include <arpa/inet.h>
 #include <asm/types.h>
 #include <error.h>
-- 
2.2.0.rc0.207.ga3a616c
