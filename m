From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] selftests/bpf: get rid of -D__x86_64__
Date: Thu, 11 May 2017 15:02:46 -0400 (EDT)
Message-ID: <20170511.150246.650724054596949813.davem@davemloft.net>
References: <d809baa4-c864-af99-38af-fbcb6637ca2b@fb.com>
        <20170504.093723.1592226593887244452.davem@davemloft.net>
        <5d1d290b-7ff7-7f9d-15a0-599596e0778c@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53282 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933927AbdEKTCy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 15:02:54 -0400
In-Reply-To: <5d1d290b-7ff7-7f9d-15a0-599596e0778c@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Thu, 4 May 2017 16:34:08 -0700

> Hence I think the cleanest solution is to have bpf arch's types.h
> either installed with llvm/gcc or picked from selftests's dir.

Something like this?

====================
[PATCH] bpf: Provide a linux/types.h override for bpf selftests.

We do not want to use the architecture's type.h header when
building BPF programs which are always 64-bit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 tools/testing/selftests/bpf/Makefile                   | 3 ++-
 tools/testing/selftests/bpf/include/uapi/linux/types.h | 6 ++++++
 2 files changed, 8 insertions(+), 1 deletion(-)
 create mode 100644 tools/testing/selftests/bpf/include/uapi/linux/types.h

diff --git a/tools/testing/selftests/bpf/Makefile b/tools/testing/selftests/bpf/Makefile
index f92f27d..f389b02 100644
--- a/tools/testing/selftests/bpf/Makefile
+++ b/tools/testing/selftests/bpf/Makefile
@@ -35,6 +35,7 @@ $(BPFOBJ): force
 CLANG ?= clang
 
 %.o: %.c
-	$(CLANG) -I. -I../../../include/uapi -I../../../../samples/bpf/ \
+	$(CLANG) -I. -I./include/uapi -I../../../include/uapi \
+		-I../../../../samples/bpf/ \
 		-Wno-compare-distinct-pointer-types \
 		-O2 -target bpf -c $< -o $@
diff --git a/tools/testing/selftests/bpf/include/uapi/linux/types.h b/tools/testing/selftests/bpf/include/uapi/linux/types.h
new file mode 100644
index 0000000..fbd16a7
--- /dev/null
+++ b/tools/testing/selftests/bpf/include/uapi/linux/types.h
@@ -0,0 +1,6 @@
+#ifndef _UAPI_LINUX_TYPES_H
+#define _UAPI_LINUX_TYPES_H
+
+#include <asm-generic/int-ll64.h>
+
+#endif /* _UAPI_LINUX_TYPES_H */
-- 
2.1.2.532.g19b5d50
