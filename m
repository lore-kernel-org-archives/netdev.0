From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 00/13] NetLabel cleanups for 2.6.20 [GIT]
Date: Fri, 17 Nov 2006 23:12:38 -0500 (EST)
Message-ID: <XMMS.LNX.4.64.0611172308070.13574@d.namei>
References: <20061117223842.399078000@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:61334 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1755952AbWKREMk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 23:12:40 -0500
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <20061117223842.399078000@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 17 Nov 2006, paul.moore@hp.com wrote:

> This patchset consists of a lot of small-ish cleanups for NetLabel and in some
> cases labeled networking in general.  I've tested these patches for the past
> few days and I haven't seen any regressions so please consider them for the
> net-2.6.20 git tree.

Thanks, excellent!

There was one minor compilation issue caused by including linux/skbuff.h 
in an SELinux header, which I fixed (see below).

Applied to
git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/selinux-net-2.6.20


---

diff --git a/security/selinux/include/security.h b/security/selinux/include/security.h
index 015f697..210eec7 100644
--- a/security/selinux/include/security.h
+++ b/security/selinux/include/security.h
@@ -8,7 +8,6 @@
 #ifndef _SELINUX_SECURITY_H_
 #define _SELINUX_SECURITY_H_
 
-#include <linux/skbuff.h>
 #include "flask.h"
 
 #define SECSID_NULL			0x00000000 /* unspecified SID */
@@ -35,6 +34,8 @@ #else
 #define POLICYDB_VERSION_MAX	POLICYDB_VERSION_RANGETRANS
 #endif
 
+struct sk_buff;
+
 extern int selinux_enabled;
 extern int selinux_mls_enabled;
 
