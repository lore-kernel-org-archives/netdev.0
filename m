From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 01/12: fix xt_LED build failure
Date: Thu, 26 Mar 2009 20:02:32 +0100 (MET)
Message-ID: <20090326190226.23365.61465.sendpatchset@x2.localnet>
References: <20090326190225.23365.96356.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090326190225.23365.96356.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit a9a9adfe2f99ddadfb574a098392a007970a1577
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Mar 25 17:21:34 2009 +0100

    netfilter: fix xt_LED build failure
    
    net/netfilter/xt_LED.c:40: error: field netfilter_led_trigger has incomplete type
    net/netfilter/xt_LED.c: In function led_timeout_callback:
    net/netfilter/xt_LED.c:78: warning: unused variable ledinternal
    net/netfilter/xt_LED.c: In function led_tg_check:
    net/netfilter/xt_LED.c:102: error: implicit declaration of function led_trigger_register
    net/netfilter/xt_LED.c: In function led_tg_destroy:
    net/netfilter/xt_LED.c:135: error: implicit declaration of function led_trigger_unregister
    
    Fix by adding a dependency on LED_TRIGGERS.
    
    Reported-by: Sachin Sant <sachinp@in.ibm.com>
    Tested-by: Subrata Modak <tosubrata@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 2562d05..2c967e4 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -374,7 +374,7 @@ config NETFILTER_XT_TARGET_HL
 
 config NETFILTER_XT_TARGET_LED
 	tristate '"LED" target support'
-	depends on LEDS_CLASS
+	depends on LEDS_CLASS && LED_TRIGGERS
 	depends on NETFILTER_ADVANCED
 	help
 	  This option adds a `LED' target, which allows you to blink LEDs in
