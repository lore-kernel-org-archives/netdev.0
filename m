From: Christian Riesch <christian.riesch@omicron.at>
Subject: [PATCH] ptp: In the testptp utility, use clock_adjtime from glibc when available
Date: Mon, 16 Jun 2014 14:46:45 +0200
Message-ID: <1402922805-3664-1-git-send-email-christian.riesch@omicron.at>
Cc: Christian Riesch <christian.riesch@omicron.at>,
	Richard Cochran <richardcochran@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay03.ispgateway.de ([80.67.31.41]:39250 "EHLO
	smtprelay03.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953AbaFPMs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2014 08:48:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

clock_adjtime was included in glibc 2.14. _GNU_SOURCE must be defined
to make it available.

Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
Cc: Richard Cochran <richardcochran@gmail.com>
---
 Documentation/ptp/testptp.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/Documentation/ptp/testptp.c b/Documentation/ptp/testptp.c
index f1ac2da..ba1d502 100644
--- a/Documentation/ptp/testptp.c
+++ b/Documentation/ptp/testptp.c
@@ -17,6 +17,7 @@
  *  along with this program; if not, write to the Free Software
  *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
+#define _GNU_SOURCE
 #include <errno.h>
 #include <fcntl.h>
 #include <inttypes.h>
@@ -46,12 +47,14 @@
 #define CLOCK_INVALID -1
 #endif
 
-/* When glibc offers the syscall, this will go away. */
+/* clock_adjtime is not available in GLIBC < 2.14 */
+#if !__GLIBC_PREREQ(2, 14)
 #include <sys/syscall.h>
 static int clock_adjtime(clockid_t id, struct timex *tx)
 {
 	return syscall(__NR_clock_adjtime, id, tx);
 }
+#endif
 
 static clockid_t get_clockid(int fd)
 {
-- 
1.7.9.5
