From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the moduleh tree with the net tree
Date: Wed, 28 Sep 2011 16:34:06 +1000
Message-ID: <20110928163406.843e4be56b42dca280d85489@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Pavel Roskin <proski@gnu.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Paul,

Today's linux-next merge of the moduleh tree got a conflict in
drivers/net/wireless/ath/ath5k/debug.c between commit 931be260ed54
("ath5k: clean up base.h and its use") from the net tree and commits
9ec3f961e31a ("drivers/net: Add export.h to files using
EXPORT_SYMBOL/THIS_MODULE") and 0cccb17382f1 ("drivers/net: Add
moduleparam.h to drivers as required") from the moduleh tree.

I fixed it up (see below) and can carry the fix as necessary.  (I am
pretty sure that this file doesn't need module.h, but not completely).
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/ath/ath5k/debug.c
index fce8c90,1051ede..0000000
--- a/drivers/net/wireless/ath/ath5k/debug.c
+++ b/drivers/net/wireless/ath/ath5k/debug.c
@@@ -58,13 -58,9 +58,15 @@@
   * THE POSSIBILITY OF SUCH DAMAGES.
   */
  
 +#include <linux/module.h>
+ #include <linux/moduleparam.h>
 -#include "base.h"
++#include <linux/export.h>
 +#include <linux/seq_file.h>
 +#include <linux/list.h>
  #include "debug.h"
 +#include "ath5k.h"
 +#include "reg.h"
 +#include "base.h"
  
  static unsigned int ath5k_debug;
  module_param_named(debug, ath5k_debug, uint, 0);
