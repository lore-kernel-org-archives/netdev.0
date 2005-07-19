From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] BRIDGE_EBT_ARPREPLY must depend on INET
Date: Tue, 19 Jul 2005 15:55:29 +0200
Message-ID: <20050719135529.GH5031@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@lists.netfilter.org, bridge@osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261917AbVGSNzu@vger.kernel.org>
To: shemminger@osdl.org, coreteam@netfilter.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

BRIDGE_EBT_ARPREPLY=y and INET=n results in the following compile error:

<--  snip  -->

...
  LD      .tmp_vmlinux1
net/built-in.o: In function `ebt_target_reply':
ebt_arpreply.c:(.text+0x68fb9): undefined reference to `arp_send'
make: *** [.tmp_vmlinux1] Error 1

<--  snip  -->

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.13-rc3-mm1-full/net/bridge/netfilter/Kconfig.old	2005-07-19 08:48:41.000000000 +0200
+++ linux-2.6.13-rc3-mm1-full/net/bridge/netfilter/Kconfig	2005-07-19 08:49:20.000000000 +0200
@@ -138,7 +138,7 @@
 #
 config BRIDGE_EBT_ARPREPLY
 	tristate "ebt: arp reply target support"
-	depends on BRIDGE_NF_EBTABLES
+	depends on BRIDGE_NF_EBTABLES && INET
 	help
 	  This option adds the arp reply target, which allows
 	  automatically sending arp replies to arp requests.
