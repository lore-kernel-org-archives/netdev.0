From: Jochen Friedrich <jochen@scram.de>
Subject: [PATCH] [PPC] Compile fix for 8xx CPM Ehernet driver
Date: Thu, 11 Oct 2007 18:41:41 +0200
Message-ID: <470E5245.8020801@scram.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------050601090006010803040305"
Cc: netdev <netdev@vger.kernel.org>,
	"linux-ppc-embedded \(\(\(\(E-Mail\)\)\)\)" <linuxppc-embedded@ozlabs.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050601090006010803040305
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit


Add #include <asm/cacheflush.h> for flush_dcache_range
to make the driver compile again.

  CC      arch/ppc/8xx_io/enet.o
arch/ppc/8xx_io/enet.c: In function 'scc_enet_start_xmit':
arch/ppc/8xx_io/enet.c:240: error: implicit declaration of function
'flush_dcache_range'
make[1]: *** [arch/ppc/8xx_io/enet.o] Error 1
make: *** [arch/ppc/8xx_io] Error 2

Signed-off-by: Jochen Friedrich <jochen@scram.de>
---
 arch/ppc/8xx_io/enet.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

--------------050601090006010803040305
Content-Type: text/x-patch;
 name="16d5c009c75feb68cf1136330efabdffbec8e095.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="16d5c009c75feb68cf1136330efabdffbec8e095.diff"

diff --git a/arch/ppc/8xx_io/enet.c b/arch/ppc/8xx_io/enet.c
index 703d47e..eace3bc 100644
--- a/arch/ppc/8xx_io/enet.c
+++ b/arch/ppc/8xx_io/enet.c
@@ -44,6 +44,7 @@
 #include <asm/mpc8xx.h>
 #include <asm/uaccess.h>
 #include <asm/commproc.h>
+#include <asm/cacheflush.h>
 
 /*
  *				Theory of Operation


--------------050601090006010803040305
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-embedded mailing list
Linuxppc-embedded@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc-embedded
--------------050601090006010803040305--
