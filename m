From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: includes build break - was Re: [net-next-2.6 PATCH v5 0/3] Introduce
 n-tuple ethtool support
Date: Sun, 14 Feb 2010 12:56:28 +0100
Message-ID: <4B77E4EC.30407@hartkopp.net>
References: <20100211020310.23436.85885.stgit@localhost.localdomain> <20100210.195445.190157100.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com
To: David Miller <davem@davemloft.net>, peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:53867 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754221Ab0BNL4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Feb 2010 06:56:50 -0500
In-Reply-To: <20100210.195445.190157100.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Wed, 10 Feb 2010 18:07:18 -0800
> 
>> One more round of fixes, based on feedback from Patrick McHardy
>>
>> 1) Change the list count to an unsigned value
>> 2) Fix a memory leak
>> 3) Removed an unnecessary list traversal in the ethtool core
>> 4) Moved all list destruction to a helper function, allowing the driver
>> to control when it clears the list (aside from when free_netdev() kills
>> the cached list).
> 
> All applied, thanks.
> 

Hi Peter,

compiling the latest net-next-2.6 i got this problem:
 
  CHECK   include/linux (358 files)
/home/hartko/net-next-2.6/usr/include/linux/ethtool.h:17: included file 'linux/rculist.h' is not exported

Which has been introduced by

http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commitdiff;h=15682bc488d4af8c9bb998844a94281025e0a333

("ethtool: Introduce n-tuple filter programming support")

The patch below fixes the issue.

Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>

---

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index a3cac53..83a9a53 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -14,7 +14,9 @@
 #define _LINUX_ETHTOOL_H
 
 #include <linux/types.h>
+#ifdef __KERNEL__
 #include <linux/rculist.h>
+#endif
 
 /* This should work for both 32 and 64 bit userland. */
 struct ethtool_cmd {
