From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v3 15/22] bpf/cgroup: Move capability check
Date: Wed, 14 Sep 2016 09:24:08 +0200
Message-ID: <20160914072415.26021-16-mic@digikod.net>
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
Return-path: <kernel-hardening-return-4595-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20160914072415.26021-1-mic@digikod.net>
List-Id: netdev.vger.kernel.org

This will be useful to be able to add more BPF attach type with
different capability checks.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Daniel Mack <daniel@zonque.org>
---
 kernel/bpf/syscall.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index c978f2d9a1b3..8599596fd6cf 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -833,15 +833,15 @@ static int bpf_prog_attach(const union bpf_attr *attr)
 	struct cgroup *cgrp;
 	int result;
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	if (CHECK_ATTR(BPF_PROG_ATTACH))
 		return -EINVAL;
 
 	switch (attr->attach_type) {
 	case BPF_CGROUP_INET_INGRESS:
 	case BPF_CGROUP_INET_EGRESS:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+
 		prog = bpf_prog_get_type(attr->attach_bpf_fd,
 					 BPF_PROG_TYPE_CGROUP_SOCKET);
 		break;
@@ -872,15 +872,15 @@ static int bpf_prog_detach(const union bpf_attr *attr)
 	struct cgroup *cgrp;
 	int result = 0;
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	if (CHECK_ATTR(BPF_PROG_DETACH))
 		return -EINVAL;
 
 	switch (attr->attach_type) {
 	case BPF_CGROUP_INET_INGRESS:
 	case BPF_CGROUP_INET_EGRESS:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+
 		cgrp = cgroup_get_from_fd(attr->target_fd);
 		if (IS_ERR(cgrp))
 			return PTR_ERR(cgrp);
-- 
2.9.3
