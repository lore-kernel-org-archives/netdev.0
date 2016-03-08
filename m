From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next 06/12] samples/bpf: make map creation more verbose
Date: Mon, 7 Mar 2016 21:57:18 -0800
Message-ID: <1457416641-306326-7-git-send-email-ast@fb.com>
References: <1457416641-306326-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Martin KaFai Lau <kafai@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:35387 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754002AbcCHF53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 00:57:29 -0500
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u285utop011349
	for <netdev@vger.kernel.org>; Mon, 7 Mar 2016 21:57:28 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 21hdu6k2nk-14
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 21:57:28 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 9fb2b944e4f211e593fa0002c9dfb610-b5ede420 for <netdev@vger.kernel.org>;	Mon,
 07 Mar 2016 21:57:21 -0800
In-Reply-To: <1457416641-306326-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

map creation is typically the first one to fail when rlimits are
too low, not enough memory, etc
Make this failure scenario more verbose

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/bpf_load.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index da86a8e0a95a..816bca5760a0 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -158,8 +158,11 @@ static int load_maps(struct bpf_map_def *maps, int len)
 					   maps[i].key_size,
 					   maps[i].value_size,
 					   maps[i].max_entries);
-		if (map_fd[i] < 0)
+		if (map_fd[i] < 0) {
+			printf("failed to create a map: %d %s\n",
+			       errno, strerror(errno));
 			return 1;
+		}
 
 		if (maps[i].type == BPF_MAP_TYPE_PROG_ARRAY)
 			prog_array_fd = map_fd[i];
-- 
2.8.0.rc1
