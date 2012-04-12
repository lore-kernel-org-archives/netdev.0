From: Will Drewry <wad@chromium.org>
Subject: [PATCH v18 05/15] seccomp: kill the seccomp_t typedef
Date: Thu, 12 Apr 2012 16:47:54 -0500
Message-ID: <1334267284-19166-5-git-send-email-wad@chromium.org>
References: <1334267284-19166-1-git-send-email-wad@chromium.org>
Cc: linux-man@vger.kernel.org, linux-security-module@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, indan@nul.nu,
	pmoore@redhat.com, akpm@linux-foundation.org, corbet@lwn.net,
	eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org,
	jmorris@namei.org, Will Drewry <wad@chromium.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1334267284-19166-1-git-send-email-wad@chromium.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replaces the seccomp_t typedef with struct seccomp to match modern
kernel style.

Signed-off-by: Will Drewry <wad@chromium.org>
Reviewed-by: James Morris <jmorris@namei.org>
Acked-by: Serge Hallyn <serge.hallyn@canonical.com>
Acked-by: Eric Paris <eparis@redhat.com>

v18: rebase
...
v14: rebase/nochanges
v13: rebase on to 88ebdda6159ffc15699f204c33feb3e431bf9bdc
v12: rebase on to linux-next
v8-v11: no changes
v7: struct seccomp_struct -> struct seccomp
v6: original inclusion in this series.
---
 include/linux/sched.h   |    2 +-
 include/linux/seccomp.h |   10 ++++++----
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index ba60897..cad1502 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1452,7 +1452,7 @@ struct task_struct {
 	uid_t loginuid;
 	unsigned int sessionid;
 #endif
-	seccomp_t seccomp;
+	struct seccomp seccomp;
 
 /* Thread group tracking */
    	u32 parent_exec_id;
diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
index cc7a4e9..d61f27f 100644
--- a/include/linux/seccomp.h
+++ b/include/linux/seccomp.h
@@ -7,7 +7,9 @@
 #include <linux/thread_info.h>
 #include <asm/seccomp.h>
 
-typedef struct { int mode; } seccomp_t;
+struct seccomp {
+	int mode;
+};
 
 extern void __secure_computing(int);
 static inline void secure_computing(int this_syscall)
@@ -19,7 +21,7 @@ static inline void secure_computing(int this_syscall)
 extern long prctl_get_seccomp(void);
 extern long prctl_set_seccomp(unsigned long);
 
-static inline int seccomp_mode(seccomp_t *s)
+static inline int seccomp_mode(struct seccomp *s)
 {
 	return s->mode;
 }
@@ -28,7 +30,7 @@ static inline int seccomp_mode(seccomp_t *s)
 
 #include <linux/errno.h>
 
-typedef struct { } seccomp_t;
+struct seccomp { };
 
 #define secure_computing(x) do { } while (0)
 
@@ -42,7 +44,7 @@ static inline long prctl_set_seccomp(unsigned long arg2)
 	return -EINVAL;
 }
 
-static inline int seccomp_mode(seccomp_t *s)
+static inline int seccomp_mode(struct seccomp *s)
 {
 	return 0;
 }
-- 
1.7.5.4

