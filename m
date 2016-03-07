From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 4/9] samples/bpf: make map creation more verbose
Date: Sun, 6 Mar 2016 17:58:32 -0800
Message-ID: <1457315917-1970307-5-git-send-email-ast@fb.com>
References: <1457315917-1970307-1-git-send-email-ast@fb.com>
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
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:38480 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751930AbcCGB6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 20:58:42 -0500
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u271riSm028851
	for <netdev@vger.kernel.org>; Sun, 6 Mar 2016 17:58:41 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 21gwus0cvu-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 06 Mar 2016 17:58:41 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 1c6fbcf2e40811e5a90824be05956610-e12e5270 for <netdev@vger.kernel.org>;	Sun,
 06 Mar 2016 17:58:39 -0800
In-Reply-To: <1457315917-1970307-1-git-send-email-ast@fb.com>
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
2.6.5
