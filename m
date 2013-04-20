From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: net: fix incorrect credentials passing
Date: Fri, 19 Apr 2013 18:32:32 -0700 (PDT)
Message-ID: <alpine.LFD.2.03.1304191826080.2455@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, "Serge E. Hallyn" <serge@hallyn.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:42108 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965367Ab3DTBcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 21:32:41 -0400
Received: by mail-pa0-f50.google.com with SMTP id bg2so2544167pad.9
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 18:32:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Commit 257b5358b32f ("scm: Capture the full credentials of the scm 
sender") changed the credentials passing code to pass in the effective 
uid/gid instead of the real uid/gid.

Obviously this doesn't matter most of the time (since normally they are 
the same), but it results in differences for suid binaries when the wrong 
uid/gid ends up being used.

This just undoes that (presumably unintentional) part of the commit.

Reported-by: Andy Lutomirski <luto@amacapital.net>
Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: Serge E. Hallyn <serge@hallyn.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: stable@vger.kernel.org
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
---

 include/net/scm.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/scm.h b/include/net/scm.h
index 975cca01048b..b11708105681 100644
--- a/include/net/scm.h
+++ b/include/net/scm.h
@@ -56,8 +56,8 @@ static __inline__ void scm_set_cred(struct scm_cookie *scm,
 	scm->pid  = get_pid(pid);
 	scm->cred = cred ? get_cred(cred) : NULL;
 	scm->creds.pid = pid_vnr(pid);
-	scm->creds.uid = cred ? cred->euid : INVALID_UID;
-	scm->creds.gid = cred ? cred->egid : INVALID_GID;
+	scm->creds.uid = cred ? cred->uid : INVALID_UID;
+	scm->creds.gid = cred ? cred->gid : INVALID_GID;
 }
 
 static __inline__ void scm_destroy_cred(struct scm_cookie *scm)
