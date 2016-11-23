From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 2/2] samples/bpf: fix bpf loader
Date: Tue, 22 Nov 2016 16:52:09 -0800
Message-ID: <1479862329-2361912-2-git-send-email-ast@fb.com>
References: <1479862329-2361912-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:48152 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753626AbcKWAw0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 19:52:26 -0500
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAN0meqO011479
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 16:52:12 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 26vwwestkf-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 16:52:12 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.222.219.45) with ESMTP id
 10d64ca8b11711e6896024be05904660-278eaa50 for <netdev@vger.kernel.org>;        Tue,
 22 Nov 2016 16:52:10 -0800
In-Reply-To: <1479862329-2361912-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

llvm can emit relocations into sections other than program code
(like debug info sections). Ignore them during parsing of elf file

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/bpf_load.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index 97913e109b14..62f54d6eb8bf 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -317,6 +317,10 @@ int load_bpf_file(char *path)
 				    &shdr_prog, &data_prog))
 				continue;
 
+			if (shdr_prog.sh_type != SHT_PROGBITS ||
+			    !(shdr_prog.sh_flags & SHF_EXECINSTR))
+				continue;
+
 			insns = (struct bpf_insn *) data_prog->d_buf;
 
 			processed_sec[shdr.sh_info] = true;
-- 
2.8.0
