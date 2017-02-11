From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH net-next v1] bpf: Remove redundant ifdef
Date: Sat, 11 Feb 2017 20:37:08 +0100
Message-ID: <20170211193708.18191-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove a useless ifdef __NR_bpf as requested by Wang Nan.

Inline one-line static functions as it was in the bpf_sys.h file.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: Wang Nan <wangnan0@huawei.com>
Link: https://lkml.kernel.org/r/828ab1ff-4dcf-53ff-c97b-074adb895006@huawei.com
---
 tools/lib/bpf/bpf.c | 12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
index 50e04cc5dddd..2de9c386989a 100644
--- a/tools/lib/bpf/bpf.c
+++ b/tools/lib/bpf/bpf.c
@@ -42,21 +42,15 @@
 # endif
 #endif
 
-static __u64 ptr_to_u64(const void *ptr)
+static inline __u64 ptr_to_u64(const void *ptr)
 {
 	return (__u64) (unsigned long) ptr;
 }
 
-static int sys_bpf(enum bpf_cmd cmd, union bpf_attr *attr,
-		   unsigned int size)
+static inline int sys_bpf(enum bpf_cmd cmd, union bpf_attr *attr,
+			  unsigned int size)
 {
-#ifdef __NR_bpf
 	return syscall(__NR_bpf, cmd, attr, size);
-#else
-	fprintf(stderr, "No bpf syscall, kernel headers too old?\n");
-	errno = ENOSYS;
-	return -1;
-#endif
 }
 
 int bpf_create_map(enum bpf_map_type map_type, int key_size,
-- 
2.11.0
