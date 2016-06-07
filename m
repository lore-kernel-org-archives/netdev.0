From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCH net-next v2 1/4] bpf: fix missing header inclusion
Date: Mon,  6 Jun 2016 22:22:56 -0700
Message-ID: <1465276979-10147-2-git-send-email-zlim.lnx@gmail.com>
References: <1465276979-10147-1-git-send-email-zlim.lnx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Yang Shi <yang.shi@linaro.org>, Daniel Borkmann <daniel@iogearbox.net>,
 Zi Shen Lim <zlim.lnx@gmail.com>, Alexei Starovoitov <ast@kernel.org>,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will.deacon@arm.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1465276979-10147-1-git-send-email-zlim.lnx@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Commit 0fc174dea545 ("ebpf: make internal bpf API independent of
CONFIG_BPF_SYSCALL ifdefs") introduced usage of ERR_PTR() in
bpf_prog_get(), however did not include linux/err.h.

Without this patch, when compiling arm64 BPF without CONFIG_BPF_SYSCALL:
...
In file included from arch/arm64/net/bpf_jit_comp.c:21:0:
include/linux/bpf.h: In function 'bpf_prog_get':
include/linux/bpf.h:235:9: error: implicit declaration of function 'ERR_PTR' [-Werror=implicit-function-declaration]
  return ERR_PTR(-EOPNOTSUPP);
         ^
include/linux/bpf.h:235:9: warning: return makes pointer from integer without a cast [-Wint-conversion]
In file included from include/linux/rwsem.h:17:0,
                 from include/linux/mm_types.h:10,
                 from include/linux/sched.h:27,
                 from arch/arm64/include/asm/compat.h:25,
                 from arch/arm64/include/asm/stat.h:23,
                 from include/linux/stat.h:5,
                 from include/linux/compat.h:12,
                 from include/linux/filter.h:10,
                 from arch/arm64/net/bpf_jit_comp.c:22:
include/linux/err.h: At top level:
include/linux/err.h:23:35: error: conflicting types for 'ERR_PTR'
 static inline void * __must_check ERR_PTR(long error)
                                   ^
In file included from arch/arm64/net/bpf_jit_comp.c:21:0:
include/linux/bpf.h:235:9: note: previous implicit declaration of 'ERR_PTR' was here
  return ERR_PTR(-EOPNOTSUPP);
         ^
...

Fixes: 0fc174dea545 ("ebpf: make internal bpf API independent of CONFIG_BPF_SYSCALL ifdefs")
Suggested-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/bpf.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 8ee27b8..1bcae82 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -11,6 +11,7 @@
 #include <linux/workqueue.h>
 #include <linux/file.h>
 #include <linux/percpu.h>
+#include <linux/err.h>
 
 struct bpf_map;
 
-- 
1.9.1
