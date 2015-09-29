From: Thomas Huth <thuth@redhat.com>
Subject: [PATCH] testptp: Silence compiler warnings on ppc64
Date: Tue, 29 Sep 2015 17:45:28 +0200
Message-ID: <1443541528-937-1-git-send-email-thuth@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: corbet@lwn.net, linux-doc@vger.kernel.org, trivial@kernel.org
To: richardcochran@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34950 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933698AbbI2Ppb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Sep 2015 11:45:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When compiling Documentation/ptp/testptp.c the following compiler
warnings are printed out:

Documentation/ptp/testptp.c: In function =E2=80=98main=E2=80=99:
Documentation/ptp/testptp.c:367:11: warning: format =E2=80=98%lld=E2=80=
=99 expects argument
    of type =E2=80=98long long int=E2=80=99, but argument 3 has type =E2=
=80=98__s64=E2=80=99 [-Wformat=3D]
           event.t.sec, event.t.nsec);
           ^
Documentation/ptp/testptp.c:505:5: warning: format =E2=80=98%lld=E2=80=99=
 expects argument
    of type =E2=80=98long long int=E2=80=99, but argument 2 has type =E2=
=80=98__s64=E2=80=99 [-Wformat=3D]
     (pct+2*i)->sec, (pct+2*i)->nsec);
     ^
Documentation/ptp/testptp.c:507:5: warning: format =E2=80=98%lld=E2=80=99=
 expects argument
    of type =E2=80=98long long int=E2=80=99, but argument 2 has type =E2=
=80=98__s64=E2=80=99 [-Wformat=3D]
     (pct+2*i+1)->sec, (pct+2*i+1)->nsec);
     ^
Documentation/ptp/testptp.c:509:5: warning: format =E2=80=98%lld=E2=80=99=
 expects argument
    of type =E2=80=98long long int=E2=80=99, but argument 2 has type =E2=
=80=98__s64=E2=80=99 [-Wformat=3D]
     (pct+2*i+2)->sec, (pct+2*i+2)->nsec);

This happens because __s64 is by default defined as "long" on ppc64,
not as "long long". However, to fix these warnings, it's possible to
define the __SANE_USERSPACE_TYPES__ so that __s64 gets defined to
"long long" on ppc64, too.

Signed-off-by: Thomas Huth <thuth@redhat.com>
---
 Documentation/ptp/testptp.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/Documentation/ptp/testptp.c b/Documentation/ptp/testptp.c
index 2bc8abc..6c6247a 100644
--- a/Documentation/ptp/testptp.c
+++ b/Documentation/ptp/testptp.c
@@ -18,6 +18,7 @@
  *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
 #define _GNU_SOURCE
+#define __SANE_USERSPACE_TYPES__        /* For PPC64, to get LL64 type=
s */
 #include <errno.h>
 #include <fcntl.h>
 #include <inttypes.h>
--=20
1.8.3.1
