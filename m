From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: linux-next: manual merge of the moduleh tree with the net tree
Date: Thu, 29 Sep 2011 16:47:52 -0400
Message-ID: <20110929204752.GA2808@windriver.com>
References: <20110928163406.843e4be56b42dca280d85489@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-next@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Pavel Roskin <proski@gnu.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110928163406.843e4be56b42dca280d85489@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[linux-next: manual merge of the moduleh tree with the net tree] On 28/09/2011 (Wed 16:34) Stephen Rothwell wrote:

> Hi Paul,
> 
> Today's linux-next merge of the moduleh tree got a conflict in
> drivers/net/wireless/ath/ath5k/debug.c between commit 931be260ed54
> ("ath5k: clean up base.h and its use") from the net tree and commits
> 9ec3f961e31a ("drivers/net: Add export.h to files using
> EXPORT_SYMBOL/THIS_MODULE") and 0cccb17382f1 ("drivers/net: Add
> moduleparam.h to drivers as required") from the moduleh tree.
> 
> I fixed it up (see below) and can carry the fix as necessary.  (I am
> pretty sure that this file doesn't need module.h, but not completely).

The conflict is gone, but you were correct in your original assessment
that the module.h was no longer needed.  I've added this to the
post-merge queue of patches.

Thanks,
Paul.

>From 13a6768b382b3d2f96b9caa9fa6df1f2f7f3aeb6 Mon Sep 17 00:00:00 2001
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Thu, 29 Sep 2011 16:37:30 -0400
Subject: [PATCH] drivers/net: wireless/ath/ath5k/debug.c does not need
 module.h

It only has module_param and EXPORT_SYMBOL, so now that export.h
is in scope at the same time as the recent ath5k update, we can
delete this module.h include.

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

diff --git a/drivers/net/wireless/ath/ath5k/debug.c b/drivers/net/wireless/ath/ath5k/debug.c
index d2bdd90..f542b41 100644
--- a/drivers/net/wireless/ath/ath5k/debug.c
+++ b/drivers/net/wireless/ath/ath5k/debug.c
@@ -59,8 +59,6 @@
  */
 #include <linux/export.h>
 #include <linux/moduleparam.h>
-
-#include <linux/module.h>
 #include <linux/seq_file.h>
 #include <linux/list.h>
 #include "debug.h"
-- 
1.7.6
