From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v2 01/10] landlock: Add Kconfig
Date: Thu, 25 Aug 2016 12:32:36 +0200
Message-ID: <1472121165-29071-2-git-send-email-mic@digikod.net>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Will Drewry <wad@chromium.org>,
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
        linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-4455-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1472121165-29071-1-git-send-email-mic@digikod.net>
List-Id: netdev.vger.kernel.org

Initial Landlock Kconfig needed to split the Landlock eBPF and seccomp
parts to ease the review.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: James Morris <james.l.morris@oracle.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Serge E. Hallyn <serge@hallyn.com>
---
 security/Kconfig          |  1 +
 security/landlock/Kconfig | 16 ++++++++++++++++
 2 files changed, 17 insertions(+)
 create mode 100644 security/landlock/Kconfig

diff --git a/security/Kconfig b/security/Kconfig
index 176758cdfa57..be6c549dd0ca 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -124,6 +124,7 @@ source security/tomoyo/Kconfig
 source security/apparmor/Kconfig
 source security/loadpin/Kconfig
 source security/yama/Kconfig
+source security/landlock/Kconfig
 
 source security/integrity/Kconfig
 
diff --git a/security/landlock/Kconfig b/security/landlock/Kconfig
new file mode 100644
index 000000000000..dc8328d216d7
--- /dev/null
+++ b/security/landlock/Kconfig
@@ -0,0 +1,16 @@
+config SECURITY_LANDLOCK
+	bool "Landlock sandbox support"
+	depends on SECURITY
+	select BPF_SYSCALL
+	select SECCOMP
+	default y
+	help
+	  Landlock is a stacked LSM which allows any user to load a security policy
+	  to restrict their processes (i.e. create a sandbox). The policy is a list
+	  of stacked eBPF programs for some LSM hooks. Each program can do some
+	  access comparison to check if an access request is legitimate.
+
+	  Further information about eBPF can be found in
+	  Documentation/networking/filter.txt
+
+	  If you are unsure how to answer this question, answer Y.
-- 
2.8.1
