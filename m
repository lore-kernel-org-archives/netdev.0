From: Sam Ravnborg <sam@ravnborg.org>
Subject: [PATCH] ieee80211: fix section mismatch warning
Date: Fri, 1 Feb 2008 12:52:06 +0100
Message-ID: <20080201115206.GA12678@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:47751 "EHLO pasmtpA.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751024AbYBALwX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 06:52:23 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the following warnings:
WARNING: net/built-in.o(.init.text+0xd6c0): Section mismatch in reference from the function ieee80211_init() to the function .exit.text:rc80211_simple_exit()
WARNING: net/built-in.o(.init.text+0xd6c5): Section mismatch in reference from the function ieee80211_init() to the function .exit.text:rc80211_pid_exit()

The fix was simple - I just did as modpost told me and removed the
wrong __exit annotation of rc80211_simple_exit and rc80211_pid_exit.

Signed-off-by: Sam Ravnborg <sam@ravnborg.org>
Cc: Johannes Berg <johannes@sipsolutions.net>
Cc: John W. Linville <linville@tuxdriver.com>
Cc: David S. Miller <davem@davemloft.net>
---

With this patch my allyesconfig build on x86 (64 bit)
is section mismatch clean in net/

	Sam

diff --git a/net/mac80211/rc80211_pid_algo.c b/net/mac80211/rc80211_pid_algo.c
index 554c4ba..c339571 100644
--- a/net/mac80211/rc80211_pid_algo.c
+++ b/net/mac80211/rc80211_pid_algo.c
@@ -538,7 +538,7 @@ int __init rc80211_pid_init(void)
 	return ieee80211_rate_control_register(&mac80211_rcpid);
 }
 
-void __exit rc80211_pid_exit(void)
+void rc80211_pid_exit(void)
 {
 	ieee80211_rate_control_unregister(&mac80211_rcpid);
 }
diff --git a/net/mac80211/rc80211_simple.c b/net/mac80211/rc80211_simple.c
index 934676d..9a78b11 100644
--- a/net/mac80211/rc80211_simple.c
+++ b/net/mac80211/rc80211_simple.c
@@ -389,7 +389,7 @@ int __init rc80211_simple_init(void)
 	return ieee80211_rate_control_register(&mac80211_rcsimple);
 }
 
-void __exit rc80211_simple_exit(void)
+void rc80211_simple_exit(void)
 {
 	ieee80211_rate_control_unregister(&mac80211_rcsimple);
 }
