From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH iproute2 2/2] Add missing <sys/types.h> include
Date: Thu, 19 Nov 2015 22:05:40 +0100
Message-ID: <1447967140-29909-3-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1447967140-29909-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:51874 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934549AbbKSVGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 16:06:07 -0500
In-Reply-To: <1447967140-29909-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The u_intXX_t types are defined in <sys/types.h>, so it should be
included before using those types. Otherwise, with certain C
libraries, the build fails with:

In file included from ../include/iptables.h:4:0,
                 from m_ipt.c:18:
=2E./include/iptables_common.h:47:16: error: unknown type name =E2=80=98=
u_int32_t=E2=80=99
 #define __le32 u_int32_t

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 include/iptables_common.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/iptables_common.h b/include/iptables_common.h
index 9099667..2c27a4b 100644
--- a/include/iptables_common.h
+++ b/include/iptables_common.h
@@ -43,6 +43,8 @@ extern char *lib_dir;
   extern void init_extensions(void);
 #endif
=20
+#include <sys/types.h>
+
 #define __be32	u_int32_t
 #define __le32	u_int32_t
 #define __be16	u_int16_t
--=20
2.6.3
