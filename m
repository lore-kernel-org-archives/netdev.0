From: David Decotigny <ddecotig@gmail.com>
Subject: [ethtool PATCH v4 01/11] internal.h: change to new sane kernel headers on 64-bit archs
Date: Fri, 11 Mar 2016 09:58:14 -0800
Message-ID: <1457719104-39188-2-git-send-email-ddecotig@gmail.com>
References: <1457719104-39188-1-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	David Decotigny <decot@googlers.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:35504 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705AbcCKR6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 12:58:37 -0500
Received: by mail-pa0-f65.google.com with SMTP id fl4so9043713pad.2
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 09:58:37 -0800 (PST)
In-Reply-To: <1457719104-39188-1-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

On ppc64, this fixes:
  In file included from ethtool-copy.h:22:0,
                   from internal.h:32,
                   from ethtool.c:29:
  .../include/linux/types.h:32:25: error: conflicting types for '__be64=
'
   typedef __u64 __bitwise __be64;
                           ^
  In file included from ethtool.c:29:0:
  internal.h:23:28: note: previous declaration of '__be64' was here
   typedef unsigned long long __be64;
                              ^
  ethtool.c: In function 'do_gstats':
  ethtool.c:3166:4: error: format '%llu' expects argument of type 'long=
 long unsigned int', but argument 5 has type '__u64' [-Werror=3Dformat=3D=
]
      stats->data[i]);
      ^
  ethtool.c: In function 'print_indir_table':
  ethtool.c:3293:9: error: format '%llu' expects argument of type 'long=
 long unsigned int', but argument 3 has type '__u64' [-Werror=3Dformat=3D=
]
           ctx->devname, ring_count->data);
           ^


Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
Signed-off-by: David Decotigny <decot@googlers.com>
---
 internal.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/internal.h b/internal.h
index b5ef646..e38d305 100644
--- a/internal.h
+++ b/internal.h
@@ -3,6 +3,12 @@
 #ifndef ETHTOOL_INTERNAL_H__
 #define ETHTOOL_INTERNAL_H__
=20
+/* Some platforms (eg. ppc64) need __SANE_USERSPACE_TYPES__ before
+ * <linux/types.h> to select 'int-ll64.h' and avoid compile warnings
+ * when printing __u64 with %llu.
+ */
+#define __SANE_USERSPACE_TYPES__
+
 #ifdef HAVE_CONFIG_H
 #include "ethtool-config.h"
 #endif
--=20
2.7.0.rc3.207.g0ac5344
