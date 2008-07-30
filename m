From: akpm@linux-foundation.org
Subject: [patch 10/12] drivers/net/ehea/ehea_main.c: release mutex in error handling code
Date: Wed, 30 Jul 2008 12:39:03 -0700
Message-ID: <200807301939.m6UJd3om012602@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, julia@diku.dk,
	ossthema@de.ibm.com, themann@de.ibm.com, tklein@de.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43693 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755591AbYG3TzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 15:55:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

The mutex is released on a successful return, so it would seem that it
should be released on an error return as well.

The semantic patch finds this problem is as follows:
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@@
expression l;
@@

mutex_lock(l);
... when != mutex_unlock(l)
    when any
    when strict
(
if (...) { ... when != mutex_unlock(l)
+   mutex_unlock(l);
    return ...;
}
|
mutex_unlock(l);
)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Jan-Bernd Themann <themann@de.ibm.com>
Cc: Thomas Klein <tklein@de.ibm.com>
Cc: Jan-Bernd Themann <ossthema@de.ibm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/ehea/ehea_main.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/ehea/ehea_main.c~drivers-net-ehea-ehea_mainc-release-mutex-in-error-handling-code drivers/net/ehea/ehea_main.c
--- a/drivers/net/ehea/ehea_main.c~drivers-net-ehea-ehea_mainc-release-mutex-in-error-handling-code
+++ a/drivers/net/ehea/ehea_main.c
@@ -2937,9 +2937,9 @@ static void ehea_rereg_mrs(struct work_s
 				}
 			}
 		}
-       mutex_unlock(&dlpar_mem_lock);
-       ehea_info("re-initializing driver complete");
+	ehea_info("re-initializing driver complete");
 out:
+	mutex_unlock(&dlpar_mem_lock);
 	return;
 }
 
_
