From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next] bpf: Fix compilation warning in __bpf_lru_list_rotate_inactive
Date: Tue, 15 Nov 2016 11:00:04 -0800
Message-ID: <1479236404-3906780-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:43665 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751633AbcKOTXL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 14:23:11 -0500
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.17/8.16.0.17) with SMTP id uAFJLGuS014007
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 11:23:10 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 26r7d3ggdt-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 11:23:10 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)     by
 mx-out.facebook.com (10.212.232.63) with ESMTP id
 b855e61cab6511e681920002c992ebde-631fca50 for <netdev@vger.kernel.org>;        Tue,
 15 Nov 2016 11:00:05 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gcc-6.2.1 gives the following warning:
kernel/bpf/bpf_lru_list.c: In function =E2=80=98__bpf_lru_list_rotate_ina=
ctive.isra.3=E2=80=99:
kernel/bpf/bpf_lru_list.c:201:28: warning: =E2=80=98next=E2=80=99 may be =
used uninitialized in this function [-Wmaybe-uninitialized]

The "next" is currently initialized in the while() loop which must have >=
=3D1
iterations.

This patch initializes next to get rid of the compiler warning.

Fixes: 3a08c2fd7634 ("bpf: LRU List")
Reported-by: David Miller <davem@davemloft.net>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 kernel/bpf/bpf_lru_list.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/bpf/bpf_lru_list.c b/kernel/bpf/bpf_lru_list.c
index bfebff0..89b7ef4 100644
--- a/kernel/bpf/bpf_lru_list.c
+++ b/kernel/bpf/bpf_lru_list.c
@@ -170,7 +170,7 @@ static void __bpf_lru_list_rotate_inactive(struct bpf=
_lru *lru,
 					   struct bpf_lru_list *l)
 {
 	struct list_head *inactive =3D &l->lists[BPF_LRU_LIST_T_INACTIVE];
-	struct list_head *cur, *next, *last;
+	struct list_head *cur, *last, *next =3D inactive;
 	struct bpf_lru_node *node;
 	unsigned int i =3D 0;
=20
--=20
2.5.1
