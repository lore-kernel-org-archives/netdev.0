From: Mathieu Olivari <mathieu@codeaurora.org>
Subject: [PATCH] net: dsa: make NET_DSA manually selectable from the config
Date: Fri, 20 Mar 2015 18:31:03 -0700
Message-ID: <1426901463-31913-1-git-send-email-mathieu@codeaurora.org>
Cc: Mathieu Olivari <mathieu@codeaurora.org>
To: davem@davemloft.net, f.fainelli@gmail.com, linux@roeck-us.net,
	jiri@resnulli.us, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:39190 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751286AbbCUBbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 21:31:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change bd76a116707bd2381da36cf7c3183df11293f1d6 made all DSA drivers
depend on NET_DSA rather than selecting them. However, as the only way
to select this option was to actually select a driver, it made DSA
impossible to enable at all.

This patch adds an explicit entry which the user will have to enable
prior selecting a driver.

Signed-off-by: Mathieu Olivari <mathieu@codeaurora.org>
---
 net/dsa/Kconfig | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index 087e654..4f3cce1 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -5,9 +5,12 @@ config HAVE_NET_DSA
 # Drivers must select NET_DSA and the appropriate tagging format
 
 config NET_DSA
-	tristate
+	tristate "Distributed Switch Architecture"
 	depends on HAVE_NET_DSA && NET_SWITCHDEV
 	select PHYLIB
+	---help---
+	  Say Y if you want to enable support for the hardware switches supported
+	  by the Distributed Switch Architecture.
 
 if NET_DSA
 
-- 
1.9.1
