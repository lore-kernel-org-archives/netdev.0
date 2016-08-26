From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFCv2 08/16] bpf: export bpf_prog_clone functions
Date: Fri, 26 Aug 2016 19:06:07 +0100
Message-ID: <1472234775-29453-9-git-send-email-jakub.kicinski@netronome.com>
References: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
        dinan.gunawardena@netronome.com, jiri@resnulli.us,
        john.fastabend@gmail.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35759 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751547AbcHZSPx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 14:15:53 -0400
Received: by mail-wm0-f47.google.com with SMTP id f65so3067239wmi.0
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 11:15:53 -0700 (PDT)
In-Reply-To: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export bpf_prog_clone_create() and bpf_prog_clone_free().

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 include/linux/bpf.h | 4 ++++
 kernel/bpf/core.c   | 8 +++++---
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 11134238417d..39f32c5ad445 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -319,4 +319,8 @@ extern const struct bpf_func_proto bpf_get_stackid_proto;
 void bpf_user_rnd_init_once(void);
 u64 bpf_user_rnd_u32(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
 
+struct bpf_prog *bpf_prog_clone_create(struct bpf_prog *fp_other,
+				       gfp_t gfp_extra_flags);
+void bpf_prog_clone_free(struct bpf_prog *fp);
+
 #endif /* _LINUX_BPF_H */
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 03fd23d4d587..c6e7ed9b6a24 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -351,8 +351,8 @@ out:
 	return to - to_buff;
 }
 
-static struct bpf_prog *bpf_prog_clone_create(struct bpf_prog *fp_other,
-					      gfp_t gfp_extra_flags)
+struct bpf_prog *bpf_prog_clone_create(struct bpf_prog *fp_other,
+				       gfp_t gfp_extra_flags)
 {
 	gfp_t gfp_flags = GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO |
 			  gfp_extra_flags;
@@ -371,8 +371,9 @@ static struct bpf_prog *bpf_prog_clone_create(struct bpf_prog *fp_other,
 
 	return fp;
 }
+EXPORT_SYMBOL_GPL(bpf_prog_clone_create);
 
-static void bpf_prog_clone_free(struct bpf_prog *fp)
+void bpf_prog_clone_free(struct bpf_prog *fp)
 {
 	/* aux was stolen by the other clone, so we cannot free
 	 * it from this path! It will be freed eventually by the
@@ -384,6 +385,7 @@ static void bpf_prog_clone_free(struct bpf_prog *fp)
 	fp->aux = NULL;
 	__bpf_prog_free(fp);
 }
+EXPORT_SYMBOL_GPL(bpf_prog_clone_free);
 
 void bpf_jit_prog_release_other(struct bpf_prog *fp, struct bpf_prog *fp_other)
 {
-- 
1.9.1
