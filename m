From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v3 12/22] bpf: Cosmetic change for bpf_prog_attach()
Date: Wed, 14 Sep 2016 09:24:05 +0200
Message-ID: <20160914072415.26021-13-mic@digikod.net>
References: <20160914072415.26021-1-mic@digikod.net>
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
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>, kernel-hardening@lists.openwall.com,
        linux-api@vger.kernel.org, linux-security-module@vger.
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-4597-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20160914072415.26021-1-mic@digikod.net>
List-Id: netdev.vger.kernel.org

Move code outside a switch/case to ease code factoring (cf. next
commit).

This apply on Daniel Mack's "Add eBPF hooks for cgroups":
https://lkml.kernel.org/r/1473696735-11269-1-git-send-email-daniel@zonque.org

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Daniel Mack <daniel@zonque.org>
---
 kernel/bpf/syscall.c | 23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index f22e3b63d253..45a91d511119 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -843,23 +843,24 @@ static int bpf_prog_attach(const union bpf_attr *attr)
 	case BPF_CGROUP_INET_EGRESS:
 		prog = bpf_prog_get_type(attr->attach_bpf_fd,
 					 BPF_PROG_TYPE_CGROUP_SOCKET);
-		if (IS_ERR(prog))
-			return PTR_ERR(prog);
-
-		cgrp = cgroup_get_from_fd(attr->target_fd);
-		if (IS_ERR(cgrp)) {
-			bpf_prog_put(prog);
-			return PTR_ERR(cgrp);
-		}
-
-		cgroup_bpf_update(cgrp, prog, attr->attach_type);
-		cgroup_put(cgrp);
 		break;
 
 	default:
 		return -EINVAL;
 	}
 
+	if (IS_ERR(prog))
+		return PTR_ERR(prog);
+
+	cgrp = cgroup_get_from_fd(attr->target_fd);
+	if (IS_ERR(cgrp)) {
+		bpf_prog_put(prog);
+		return PTR_ERR(cgrp);
+	}
+
+	cgroup_bpf_update(cgrp, prog, attr->attach_type);
+	cgroup_put(cgrp);
+
 	return 0;
 }
 
-- 
2.9.3
