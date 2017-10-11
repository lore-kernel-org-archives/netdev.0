From: Colin King <colin.king@canonical.com>
Subject: [PATCH][bpf-next] bpf: remove redundant variable old_flags
Date: Wed, 11 Oct 2017 11:56:23 +0100
Message-ID: <20171011105623.19998-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Variable old_flags is being assigned but is never read; it is redundant
and can be removed.

Cleans up clang warning: Value stored to 'old_flags' is never read

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 kernel/bpf/cgroup.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
index e88abc0865d5..3db5a17fcfe8 100644
--- a/kernel/bpf/cgroup.c
+++ b/kernel/bpf/cgroup.c
@@ -192,7 +192,6 @@ int __cgroup_bpf_attach(struct cgroup *cgrp, struct bpf_prog *prog,
 	struct cgroup_subsys_state *css;
 	struct bpf_prog_list *pl;
 	bool pl_was_allocated;
-	u32 old_flags;
 	int err;
 
 	if ((flags & BPF_F_ALLOW_OVERRIDE) && (flags & BPF_F_ALLOW_MULTI))
@@ -239,7 +238,6 @@ int __cgroup_bpf_attach(struct cgroup *cgrp, struct bpf_prog *prog,
 		pl->prog = prog;
 	}
 
-	old_flags = cgrp->bpf.flags[type];
 	cgrp->bpf.flags[type] = flags;
 
 	/* allocate and recompute effective prog arrays */
-- 
2.14.1
