From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the moduleh tree
Date: Wed, 28 Sep 2011 18:35:52 +1000
Message-ID: <20110928183552.cb27a2b28b02fec275bca009@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Kalle Valo <kvalo@qca.qualcomm.com>,
	Vasanthakumar Thiagarajan <vthiagar@qca.qualcomm.com>,
	Raja Mani <rmani@qca.qualcomm.com>,
	Vivek Natarajan <nataraja@qca.qualcomm.com>,
	Suraj Sumangala <surajs@qca.qualcomm.com>,
	Joe Perches <joe@perches.com>,
	Jouni Malinen <jouni@qca.qualcomm.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Paul,

After merging the moduleh tree, today's linux-next build (x86_64
allmodconfig) failed like this:

drivers/net/wireless/ath/ath6kl/init.c:27:26: error: expected ')' before 'uint'

Caused by commit bdcd81707973 ("Add ath6kl cleaned up driver") from the
net tree interacting with the module.h split up.

I have applied the following patch for today (which sould be applied to
the net or wireless trees).

>From 1875bfc8881cca3064c7d7fad024555fe1652926 Mon Sep 17 00:00:00 2001
From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 28 Sep 2011 18:32:34 +1000
Subject: [PATCH] wireless/ath6kl: use of module_param requires the inclusion
 of moduleparam.h

Otheriwse the module.h split up fails like this:

drivers/net/wireless/ath/ath6kl/init.c:27:26: error: expected ')' before 'uint'

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/wireless/ath/ath6kl/init.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/init.c b/drivers/net/wireless/ath/ath6kl/init.c
index 9d10322..8552da0 100644
--- a/drivers/net/wireless/ath/ath6kl/init.c
+++ b/drivers/net/wireless/ath/ath6kl/init.c
@@ -15,6 +15,7 @@
  * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
+#include <linux/moduleparam.h>
 #include <linux/mmc/sdio_func.h>
 #include "core.h"
 #include "cfg80211.h"
-- 
1.7.6.3

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
