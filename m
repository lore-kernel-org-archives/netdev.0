From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] uapi glibc compat: fix compilation when !__USE_MISC in glibc
Date: Thu, 19 May 2016 17:26:29 +0200
Message-ID: <1463671589-21327-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Jan Engelhardt <jengelh@inai.de>,
	Josh Boyer <jwboyer@fedoraproject.org>,
	Stephen Hemminger <shemming@brocade.com>,
	Waldemar Brodkorb <mail@waldemar-brodkorb.de>,
	Gabriel Laskar <gabriel@lse.epita.fr>,
	Mikko Rapeli <mikko.rapeli@iki.fi>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:50013 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754395AbcESP1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 11:27:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These structures are defined only if __USE_MISC is set in glibc net/if.h
headers, ie when _BSD_SOURCE or _SVID_SOURCE are defined.

CC: Jan Engelhardt <jengelh@inai.de>
CC: Josh Boyer <jwboyer@fedoraproject.org>
CC: Stephen Hemminger <shemming@brocade.com>
CC: Waldemar Brodkorb <mail@waldemar-brodkorb.de>
CC: Gabriel Laskar <gabriel@lse.epita.fr>
CC: Mikko Rapeli <mikko.rapeli@iki.fi>
Fixes: 4a91cb61bb99 ("uapi glibc compat: fix compile errors when glibc net/if.h included before linux/if.h")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/libc-compat.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/libc-compat.h b/include/uapi/linux/libc-compat.h
index d5e38c73377c..e4f048ee7043 100644
--- a/include/uapi/linux/libc-compat.h
+++ b/include/uapi/linux/libc-compat.h
@@ -52,7 +52,7 @@
 #if defined(__GLIBC__)
 
 /* Coordinate with glibc net/if.h header. */
-#if defined(_NET_IF_H)
+#if defined(_NET_IF_H) && defined(__USE_MISC)
 
 /* GLIBC headers included first so don't define anything
  * that would already be defined. */
-- 
2.8.1
