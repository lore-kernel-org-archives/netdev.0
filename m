From: Jiri Kosina <jikos@kernel.org>
Subject: [PATCH] iproute2: tc: introduce build dependency on libnetlink
Date: Fri, 24 Feb 2017 18:28:54 +0100 (CET)
Message-ID: <alpine.LSU.2.20.1702241826540.24579@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:60332 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751232AbdBXSnq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Feb 2017 13:43:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Kosina <jkosina@suse.cz>

Rebuilding libnetlink doesn't trigger rebuild of tc, which is wrong 
(especially so for builds where libnetlink.a gets statically linked into 
tc). Fix that by introducing an explicit dependency.

Signed-off-by: Jiri Kosina <jkosina@suse.cz>
---
 tc/Makefile | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tc/Makefile b/tc/Makefile
index 6dd984f0..3f7fc939 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -127,7 +127,7 @@ MODDESTDIR := $(DESTDIR)$(LIBDIR)/tc
 
 all: tc $(TCSO)
 
-tc: $(TCOBJ) libtc.a
+tc: $(TCOBJ) $(LIBNETLINK) libtc.a
 	$(QUIET_LINK)$(CC) $^ $(LDFLAGS) $(LDLIBS) -o $@
 
 libtc.a: $(TCLIB)

-- 
Jiri Kosina
SUSE Labs
