From: Chris Wedgwood <cw@f00f.org>
Subject: [PATCH] Disable multipath cache routing
Date: Fri, 19 May 2006 19:52:43 -0700
Message-ID: <20060520025243.GA9486@taniwha.stupidest.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp113.sbc.mail.mud.yahoo.com ([68.142.198.212]:3767 "HELO
	smtp113.sbc.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S964802AbWETCwq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 May 2006 22:52:46 -0400
To: netdev <netdev@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Apparently IP_ROUTE_MULTIPATH_CACHED isn't entirely safe to use and
will oops the kernel "sooner or later".  The Kconfig comment says
EXPERIMENTAL but it's not.

Let's go further and mark it BROKEN for now (leaving the comment as-is
though).  If nobody steps up to resurrect this code we can discuss
removing it entirely.


Signed-off-by: Chris Wedgwood <cw@f00f.org>

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 011cca7..3a08b9e 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -124,7 +124,7 @@ config IP_ROUTE_MULTIPATH
 
 config IP_ROUTE_MULTIPATH_CACHED
 	bool "IP: equal cost multipath with caching support (EXPERIMENTAL)"
-	depends on IP_ROUTE_MULTIPATH
+	depends on IP_ROUTE_MULTIPATH && BROKEN
 	help
 	  Normally, equal cost multipath routing is not supported by the
 	  routing cache. If you say Y here, alternative routes are cached
