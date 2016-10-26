From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v4 01/18] landlock: Add Kconfig
Date: Wed, 26 Oct 2016 08:56:37 +0200
Message-ID: <20161026065654.19166-2-mic@digikod.net>
References: <20161026065654.19166-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Jann Horn <jann@thejh.net>, Kees Cook <keescook@chromium.org>,
        Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Thomas Graf <tgraf@suug.ch>, Will Drewry <wad@chromium.org>,
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
        linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
        cgroups@v
To: linux-kernel@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20161026065654.19166-1-mic@digikod.net>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

Initial Landlock Kconfig needed to split the Landlock eBPF and seccomp
parts to ease the review.

Changes from v2:
* add seccomp filter or cgroups (with eBPF programs attached support)
  dependencies

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: James Morris <james.l.morris@oracle.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Serge E. Hallyn <serge@hallyn.com>
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

