From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v2 net-next 6/8] bpf: Add jited_len to struct bpf_prog
Date: Wed, 31 May 2017 11:59:00 -0700
Message-ID: <3714ff1ed451b788635fd014f6f935823ee12344.1496256722.git.kafai@fb.com>
References: <cover.1496256722.git.kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:33305 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751000AbdEaS7F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 14:59:05 -0400
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4VIvSPP029173
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 11:59:04 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2at3ae82cf-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 11:59:04 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.102.107.99) with ESMTP id
 36a9e23a463311e788f60002c99293a0-f15388f0 for <netdev@vger.kernel.org>;        Wed,
 31 May 2017 11:59:03 -0700
In-Reply-To: <cover.1496256722.git.kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add jited_len to struct bpf_prog.  It will be
useful for the struct bpf_prog_info which will
be added in the later patch.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 arch/arm64/net/bpf_jit_comp.c     | 1 +
 arch/powerpc/net/bpf_jit_comp64.c | 1 +
 arch/s390/net/bpf_jit_comp.c      | 1 +
 arch/sparc/net/bpf_jit_comp_64.c  | 1 +
 arch/x86/net/bpf_jit_comp.c       | 1 +
 include/linux/filter.h            | 1 +
 6 files changed, 6 insertions(+)

diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index 71f930501ade..6b21dccf01e8 100644
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -900,6 +900,7 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
 	bpf_jit_binary_lock_ro(header);
 	prog->bpf_func = (void *)ctx.image;
 	prog->jited = 1;
+	prog->jited_len = image_size;
 
 out_off:
 	kfree(ctx.offset);
diff --git a/arch/powerpc/net/bpf_jit_comp64.c b/arch/powerpc/net/bpf_jit_comp64.c
index aee2bb817ac6..a3f904cd8b1e 100644
--- a/arch/powerpc/net/bpf_jit_comp64.c
+++ b/arch/powerpc/net/bpf_jit_comp64.c
@@ -1052,6 +1052,7 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *fp)
 
 	fp->bpf_func = (void *)image;
 	fp->jited = 1;
+	fp->jited_len = alloclen;
 
 	bpf_flush_icache(bpf_hdr, (u8 *)bpf_hdr + (bpf_hdr->pages * PAGE_SIZE));
 
diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index 6e97a2e3fd8d..76b7e9d5d591 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -1329,6 +1329,7 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *fp)
 	bpf_jit_binary_lock_ro(header);
 	fp->bpf_func = (void *) jit.prg_buf;
 	fp->jited = 1;
+	fp->jited_len = jit.size;
 free_addrs:
 	kfree(jit.addrs);
 out:
diff --git a/arch/sparc/net/bpf_jit_comp_64.c b/arch/sparc/net/bpf_jit_comp_64.c
index 21de77419f48..beb46b14fbbc 100644
--- a/arch/sparc/net/bpf_jit_comp_64.c
+++ b/arch/sparc/net/bpf_jit_comp_64.c
@@ -1555,6 +1555,7 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
 
 	prog->bpf_func = (void *)ctx.image;
 	prog->jited = 1;
+	prog->jited_len = image_size;
 
 out_off:
 	kfree(ctx.offset);
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index f58939393eef..9341030133ae 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -1162,6 +1162,7 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
 		bpf_jit_binary_lock_ro(header);
 		prog->bpf_func = (void *)image;
 		prog->jited = 1;
+		prog->jited_len = proglen;
 	} else {
 		prog = orig_prog;
 	}
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 62d948f80730..a322a41f394b 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -429,6 +429,7 @@ struct bpf_prog {
 	kmemcheck_bitfield_end(meta);
 	enum bpf_prog_type	type;		/* Type of BPF program */
 	u32			len;		/* Number of filter blocks */
+	u32			jited_len;	/* Size of jited insns in bytes */
 	u8			tag[BPF_TAG_SIZE];
 	struct bpf_prog_aux	*aux;		/* Auxiliary fields */
 	struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
-- 
2.9.3
