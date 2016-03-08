From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next 04/12] bpf: check for reserved flag bits in array and stack maps
Date: Mon, 7 Mar 2016 21:57:16 -0800
Message-ID: <1457416641-306326-5-git-send-email-ast@fb.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457416641-306326-1-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Suggested-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/arraymap.c | 2 +-
 kernel/bpf/stackmap.c | 3 +++
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index bd3bdf2486a7..76d5a794e426 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -53,7 +53,7 @@ static struct bpf_map *array_map_alloc(union bpf_attr *attr)
 
 	/* check sanity of attributes */
 	if (attr->max_entries == 0 || attr->key_size != 4 ||
-	    attr->value_size == 0)
+	    attr->value_size == 0 || attr->map_flags)
 		return ERR_PTR(-EINVAL);
 
 	if (attr->value_size >= 1 << (KMALLOC_SHIFT_MAX - 1))
diff --git a/kernel/bpf/stackmap.c b/kernel/bpf/stackmap.c
index 8a60ee14a977..f0a02c344358 100644
--- a/kernel/bpf/stackmap.c
+++ b/kernel/bpf/stackmap.c
@@ -35,6 +35,9 @@ static struct bpf_map *stack_map_alloc(union bpf_attr *attr)
 	if (!capable(CAP_SYS_ADMIN))
 		return ERR_PTR(-EPERM);
 
+	if (attr->map_flags)
+		return ERR_PTR(-EINVAL);
+
 	/* check sanity of attributes */
 	if (attr->max_entries == 0 || attr->key_size != 4 ||
 	    value_size < 8 || value_size % 8 ||
-- 
2.8.0.rc1
