From: Boqun Feng <boqun.feng@gmail.com>
Subject: [PATCH] atomics,cmpxchg: Privatize the inclusion of asm/cmpxchg.h
Date: Wed, 26 Aug 2015 19:52:46 +0800
Message-ID: <1440589966-26280-1-git-send-email-boqun.feng@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Kirk Reiser <kirk@reisers.ca>,
 linux-net-drivers@solarflare.com, Davidlohr Bueso <dave@stgolabs.net>,
 linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>,
 Peter Zijlstra <peterz@infradead.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Boqun Feng <boqun.feng@gmail.com>, Will Deacon <will.deacon@arm.com>,
 Kishon Vijay Abraham I <kishon@ti.com>, speakup@linux-speakup.org,
 Ingo Molnar <mingo@redhat.com>, Shradha Shah <sshah@solarflare.com>,
 Samuel Thibault <samuel.thibault@ens-lyon.org>, netdev@vger.kernel.org,
 Chris Brannon <chris@the-brannons.com>
To: linux-kernel@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

After commit:

atomics: add acquire/release/relaxed variants of some atomic operations

Architectures may only provide {cmp,}xchg_relaxed definitions in
asm/cmpxchg.h. Other variants, such as {cmp,}xchg, may be built in
linux/atomic.h, which means simply including asm/cmpxchg.h may not get
the definitions of all the{cmp,}xchg variants. Therefore, we should
privatize the inclusions of asm/cmpxchg.h to keep it only included in
arch/* and replace the inclusions outside with linux/atomic.h

Acked-by: Will Deacon <will.deacon@arm.com>
Signed-off-by: Boqun Feng <boqun.feng@gmail.com>
---
 Documentation/atomic_ops.txt        | 4 ++++
 drivers/net/ethernet/sfc/mcdi.c     | 2 +-
 drivers/phy/phy-rcar-gen2.c         | 3 +--
 drivers/staging/speakup/selection.c | 2 +-
 4 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/Documentation/atomic_ops.txt b/Documentation/atomic_ops.txt
index b19fc34..c9d1cac 100644
--- a/Documentation/atomic_ops.txt
+++ b/Documentation/atomic_ops.txt
@@ -542,6 +542,10 @@ The routines xchg() and cmpxchg() must provide the same exact
 memory-barrier semantics as the atomic and bit operations returning
 values.
 
+Note: If someone wants to use xchg(), cmpxchg() and their variants,
+linux/atomic.h should be included rather than asm/cmpxchg.h, unless
+the code is in arch/* and can take care of itself.
+
 Spinlocks and rwlocks have memory barrier expectations as well.
 The rule to follow is simple:
 
diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 81640f8..968383e 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -9,7 +9,7 @@
 
 #include <linux/delay.h>
 #include <linux/moduleparam.h>
-#include <asm/cmpxchg.h>
+#include <linux/atomic.h>
 #include "net_driver.h"
 #include "nic.h"
 #include "io.h"
diff --git a/drivers/phy/phy-rcar-gen2.c b/drivers/phy/phy-rcar-gen2.c
index 39d9b29..117b495 100644
--- a/drivers/phy/phy-rcar-gen2.c
+++ b/drivers/phy/phy-rcar-gen2.c
@@ -17,8 +17,7 @@
 #include <linux/phy/phy.h>
 #include <linux/platform_device.h>
 #include <linux/spinlock.h>
-
-#include <asm/cmpxchg.h>
+#include <linux/atomic.h>
 
 #define USBHS_LPSTS			0x02
 #define USBHS_UGCTRL			0x80
diff --git a/drivers/staging/speakup/selection.c b/drivers/staging/speakup/selection.c
index a031570..81c0888 100644
--- a/drivers/staging/speakup/selection.c
+++ b/drivers/staging/speakup/selection.c
@@ -7,7 +7,7 @@
 #include <linux/workqueue.h>
 #include <linux/tty.h>
 #include <linux/tty_flip.h>
-#include <asm/cmpxchg.h>
+#include <linux/atomic.h>
 
 #include "speakup.h"
 
-- 
2.5.0
