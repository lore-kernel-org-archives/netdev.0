From: Josh Triplett <josh@joshtriplett.org>
Subject: [PATCH RESEND] uts: Set default hostname to "localhost", rather than
 "(none)"
Date: Sun, 10 Apr 2011 22:01:59 -0700
Message-ID: <20110411050155.GA2507@feather>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:51381 "EHLO
	relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752412Ab1DKFIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 01:08:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The "hostname" tool falls back to setting the hostname to "localhost" if
/etc/hostname does not exist.  Distribution init scripts have the same
fallback.  However, if userspace never calls sethostname, such as when
booting with init=/bin/sh, or otherwise booting a minimal system without
the usual init scripts, the default hostname of "(none)" remains,
unhelpfully appearing in various places such as prompts
("root@(none):~#") and logs.  Furthrmore, "(none)" doesn't typically
resolve to anything useful, while "localhost" does.

Change the default hostname to "localhost".  This removes the need for
the standard fallback, provides a useful default for systems that never
call sethostname, and makes minimal systems that much more useful with
less configuration.

Signed-off-by: Josh Triplett <josh@joshtriplett.org>
---

Looked at "(none)" one too many times, and figured I ought to do
something about it.

Resending, and adding CCs for networking and UTS.

 include/linux/uts.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/uts.h b/include/linux/uts.h
index 73eb1ed..610bec2 100644
--- a/include/linux/uts.h
+++ b/include/linux/uts.h
@@ -9,7 +9,7 @@
 #endif
 
 #ifndef UTS_NODENAME
-#define UTS_NODENAME "(none)"	/* set by sethostname() */
+#define UTS_NODENAME "localhost"	/* set by sethostname() */
 #endif
 
 #ifndef UTS_DOMAINNAME
-- 
1.7.4.1

