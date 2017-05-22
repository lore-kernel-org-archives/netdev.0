From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH 2/2] Add missing <sys/types.h> include
Date: Mon, 22 May 2017 16:27:54 +0300
Message-ID: <5cdba9c8dc972d25219517ade6129faf73f459b3.1495459674.git.baruch@tkos.co.il>
References: <8afdd8babb9e82bcfde78e851b24b698436a6f9f.1495459674.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Baruch Siach <baruch@tkos.co.il>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from guitar.tcltek.co.il ([192.115.133.116]:41567 "EHLO
        mx.tkos.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759660AbdEVN2H (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 09:28:07 -0400
In-Reply-To: <8afdd8babb9e82bcfde78e851b24b698436a6f9f.1495459674.git.baruch@tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

The u_intXX_t types are defined in <sys/types.h>, so it should be
included before using those types. Otherwise, with certain C
libraries, the build fails with:

In file included from ../include/iptables.h:4:0,
                 from m_ipt.c:18:
../include/iptables_common.h:47:16: error: unknown type name ‘u_int32_t’
 #define __le32 u_int32_t

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Signed-off-by: Baruch Siach <baruch@tkos.co.il>
---
 include/iptables_common.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/iptables_common.h b/include/iptables_common.h
index 9099667ffa6d..2c27a4b61fcd 100644
--- a/include/iptables_common.h
+++ b/include/iptables_common.h
@@ -43,6 +43,8 @@ extern char *lib_dir;
   extern void init_extensions(void);
 #endif
 
+#include <sys/types.h>
+
 #define __be32	u_int32_t
 #define __le32	u_int32_t
 #define __be16	u_int16_t
-- 
2.11.0
