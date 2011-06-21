From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the staging tree with the trivial and
 net trees
Date: Tue, 21 Jun 2011 15:10:55 +1000
Message-ID: <20110621151055.0775f17a.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Vitaliy Ivanov <vitalivanov@gmail.com>,
	Jiri Kosina <jkosina@suse.cz>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:52868 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752426Ab1FUFK5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2011 01:10:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Greg,

Today's linux-next merge of the staging tree got a conflict in
drivers/staging/brcm80211/brcmfmac/wl_iw.c between commit e44ba033c565
("treewide: remove duplicate includes") from the trivial tree, commit
219eb47e6f35 ("net/staging: add needed interrupt.h and hardirq.h
includes") from the net tree and various commits from the staging tree.

I fixed them up (see below) and can carry the fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/staging/brcm80211/brcmfmac/wl_iw.c
index 53e6a10,9e4b087..0000000
--- a/drivers/staging/brcm80211/brcmfmac/wl_iw.c
+++ b/drivers/staging/brcm80211/brcmfmac/wl_iw.c
@@@ -16,21 -16,30 +16,30 @@@
  
  #include <linux/kthread.h>
  #include <linux/semaphore.h>
- #include <bcmdefs.h>
+ #include <defs.h>
  #include <linux/netdevice.h>
 +#include <linux/hardirq.h>
- #include <wlioctl.h>
- #include <bcmutils.h>
+ #include <linux/etherdevice.h>
+ #include <linux/wireless.h>
 +#include <linux/if_arp.h>
- #include <asm/uaccess.h>
 +#include <linux/ieee80211.h>
 +
++#include <asm/uaccess.h>
+ 
+ #include <brcmu_utils.h>
+ #include <brcmu_wifi.h>
+ 
 -#include <linux/if_arp.h>
 -#include <asm/uaccess.h>
 -
  #include <dngl_stats.h>
  #include <dhd.h>
- #include <dhdioctl.h>
 -#include <linux/ieee80211.h>
+ 
+ struct si_pub;
  
 -#include <dngl_stats.h>
 -#include <dhd.h>
 +typedef const struct si_pub si_t;
  
+ #define WPA_OUI			"\x00\x50\xF2"
+ #define DOT11_MNG_RSN_ID			48
+ #define DOT11_MNG_WPA_ID			221
+ 
  #define WL_ERROR(fmt, args...)	printk(fmt, ##args)
  #define WL_TRACE(fmt, args...)	no_printk(fmt, ##args)
  #define WL_INFORM(fmt, args...)	no_printk(fmt, ##args)
