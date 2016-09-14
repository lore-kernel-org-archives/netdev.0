From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Subject: [RFC v3 01/22] landlock: Add Kconfig
Date: Wed, 14 Sep 2016 09:23:54 +0200
Message-ID: <20160914072415.26021-2-mic@digikod.net>
References: <20160914072415.26021-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>,
        Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        David Drysdale <drysdale-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>,
        "Serge E . Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160914072415.26021-1-mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Initial Landlock Kconfig needed to split the Landlock eBPF and seccomp
parts to ease the review.

Changes from v2:
* add seccomp filter or cgroups (with eBPF programs attached support)
  dependencies

Signed-off-by: Mickaël Salaün <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Cc: James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: Serge E. Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
---
 security/Kconfig          |  1 +
 security/landlock/Kconfig | 23 +++++++++++++++++++++++
 2 files changed, 24 insertions(+)
 create mode 100644 security/landlock/Kconfig

diff --git a/security/Kconfig b/security/Kconfig
index 118f4549404e..c63194c561c5 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -164,6 +164,7 @@ source security/tomoyo/Kconfig
 source security/apparmor/Kconfig
 source security/loadpin/Kconfig
 source security/yama/Kconfig
+source security/landlock/Kconfig
 
 source security/integrity/Kconfig
 
diff --git a/security/landlock/Kconfig b/security/landlock/Kconfig
new file mode 100644
index 000000000000..dec64270b06d
--- /dev/null
+++ b/security/landlock/Kconfig
@@ -0,0 +1,23 @@
+config SECURITY_LANDLOCK
+	bool "Landlock sandbox support"
+	depends on SECURITY
+	depends on BPF_SYSCALL
+	depends on SECCOMP_FILTER || CGROUP_BPF
+	default y
+	help
+	  Landlock is a stacked LSM which allows any user to load a security
+	  policy to restrict their processes (i.e. create a sandbox). The
+	  policy is a list of stacked eBPF programs for some LSM hooks. Each
+	  program can do some access comparison to check if an access request
+	  is legitimate.
+
+	  You need to enable seccomp filter and/or cgroups (with eBPF programs
+	  attached support) to apply a security policy to either a process
+	  hierarchy (e.g. application with built-in sandboxing) or a group of
+	  processes (e.g. container sandboxing). It is recommended to enable
+	  both seccomp filter and cgroups.
+
+	  Further information about eBPF can be found in
+	  Documentation/networking/filter.txt
+
+	  If you are unsure how to answer this question, answer Y.
-- 
2.9.3
