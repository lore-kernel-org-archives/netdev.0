From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Allow building iwl3945 without iwl4965.
Date: Sun, 27 Apr 2008 15:43:08 -0700 (PDT)
Message-ID: <20080427.154308.207402253.davem@davemloft.net>
References: <87zlrgl09s.fsf@sparse.dyndns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yi.zhu@intel.com, netdev@vger.kernel.org
To: jason@acm.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36266
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751936AbYD0WnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 18:43:08 -0400
In-Reply-To: <87zlrgl09s.fsf@sparse.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Riedy <jason@acm.org>
Date: Sat, 26 Apr 2008 15:27:43 -0700

> If IWL3945 ever depends on IWLCORE, the silent, user-invisible
> IWLWIFI option can go away.
> 
> Signed-off-by: Jason Riedy <jason@acm.org>

Patch applied, thanks a lot jason.

>    The breakage made it to Linus's tree but isn't in the wireless forest
>    (as far as I can see).  Commit 49186b4a083655 is a "part 2" without
>    a "part 1", so perhaps that "part 1" avoided the problem?

No, the "part 1" is exactly the patch posted by Tomas Winkler
and referenced in the 49186b4a083655 commit, which is:

commit d7d313000ba2fc94a5383511a17ff38a39bab928
Author: Tomas Winkler <tomas.winkler@intel.com>
Date:   Wed Apr 23 03:48:57 2008 -0700

    iwlwifi: Fix built-in compilation of iwlcore
    
    This patch fixes problem in Makefile that prevented
    built-in compilation of iwlcore
    
    Commit that caused this problem: eadd3c4b ("iwlwifi: make Makefile
    more concise")
    
    Signed-off-by: Tomas Winkler <tomas.winkler@intel.com>
    Signed-off-by: Yi Zhu <yi.zhu@intel.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/wireless/iwlwifi/Makefile b/drivers/net/wireless/iwlwifi/Makefile
index 4f3e88b..ec6187b 100644
--- a/drivers/net/wireless/iwlwifi/Makefile
+++ b/drivers/net/wireless/iwlwifi/Makefile
@@ -1,4 +1,4 @@
-obj-$(CONFIG_IWLCORE)	:= iwlcore.o
+obj-$(CONFIG_IWLCORE)	+= iwlcore.o
 iwlcore-objs 		:= iwl-core.o iwl-eeprom.o iwl-hcmd.o
 iwlcore-$(CONFIG_IWLWIFI_DEBUGFS) += iwl-debugfs.o
 iwlcore-$(CONFIG_IWLWIFI_LEDS) += iwl-led.o
