From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v4 15/18] bpf/cgroup: Move capability check
Date: Wed, 26 Oct 2016 08:56:51 +0200
Message-ID: <20161026065654.19166-16-mic@digikod.net>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-sh2.infomaniak.ch ([128.65.195.6]:45482 "EHLO
        smtp-sh2.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754258AbcJZG6b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 02:58:31 -0400
In-Reply-To: <20161026065654.19166-1-mic@digikod.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
index e62123aeb202..128acb4f7177 100644
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
 					 BPF_PROG_TYPE_CGROUP_SKB);
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
