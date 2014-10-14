From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH net] net: filter: move common defines into bpf_common.h
Date: Tue, 14 Oct 2014 02:08:54 -0700
Message-ID: <1413277734-13053-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

userspace programs that use eBPF instruction macros need to include two files:
uapi/linux/filter.h and uapi/linux/bpf.h
Move common macro definitions that are shared between classic BPF and eBPF
into uapi/linux/bpf_common.h, so that user app can include only one bpf.h file

Cc: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
---

Daniel believes that this patch has to be done for this merge window.
I think it can wait till next, but it won't hurt now either.

 include/uapi/linux/Kbuild       |    1 +
 include/uapi/linux/bpf.h        |    1 +
 include/uapi/linux/bpf_common.h |   55 ++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/filter.h     |   56 +--------------------------------------
 4 files changed, 58 insertions(+), 55 deletions(-)
 create mode 100644 include/uapi/linux/bpf_common.h

diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index 70e150e..1115d68 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -68,6 +68,7 @@ header-y += binfmts.h
 header-y += blkpg.h
 header-y += blktrace_api.h
 header-y += bpf.h
+header-y += bpf_common.h
 header-y += bpqether.h
 header-y += bsg.h
 header-y += btrfs.h
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 31b0ac2..d18316f 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -8,6 +8,7 @@
 #define _UAPI__LINUX_BPF_H__
 
 #include <linux/types.h>
+#include <linux/bpf_common.h>
 
 /* Extended instruction set based on top of classic BPF */
 
diff --git a/include/uapi/linux/bpf_common.h b/include/uapi/linux/bpf_common.h
new file mode 100644
index 0000000..a5c220e
--- /dev/null
+++ b/include/uapi/linux/bpf_common.h
@@ -0,0 +1,55 @@
+#ifndef _UAPI__LINUX_BPF_COMMON_H__
+#define _UAPI__LINUX_BPF_COMMON_H__
+
+/* Instruction classes */
+#define BPF_CLASS(code) ((code) & 0x07)
+#define		BPF_LD		0x00
+#define		BPF_LDX		0x01
+#define		BPF_ST		0x02
+#define		BPF_STX		0x03
+#define		BPF_ALU		0x04
+#define		BPF_JMP		0x05
+#define		BPF_RET		0x06
+#define		BPF_MISC        0x07
+
+/* ld/ldx fields */
+#define BPF_SIZE(code)  ((code) & 0x18)
+#define		BPF_W		0x00
+#define		BPF_H		0x08
+#define		BPF_B		0x10
+#define BPF_MODE(code)  ((code) & 0xe0)
+#define		BPF_IMM		0x00
+#define		BPF_ABS		0x20
+#define		BPF_IND		0x40
+#define		BPF_MEM		0x60
+#define		BPF_LEN		0x80
+#define		BPF_MSH		0xa0
+
+/* alu/jmp fields */
+#define BPF_OP(code)    ((code) & 0xf0)
+#define		BPF_ADD		0x00
+#define		BPF_SUB		0x10
+#define		BPF_MUL		0x20
+#define		BPF_DIV		0x30
+#define		BPF_OR		0x40
+#define		BPF_AND		0x50
+#define		BPF_LSH		0x60
+#define		BPF_RSH		0x70
+#define		BPF_NEG		0x80
+#define		BPF_MOD		0x90
+#define		BPF_XOR		0xa0
+
+#define		BPF_JA		0x00
+#define		BPF_JEQ		0x10
+#define		BPF_JGT		0x20
+#define		BPF_JGE		0x30
+#define		BPF_JSET        0x40
+#define BPF_SRC(code)   ((code) & 0x08)
+#define		BPF_K		0x00
+#define		BPF_X		0x08
+
+#ifndef BPF_MAXINSNS
+#define BPF_MAXINSNS 4096
+#endif
+
+#endif /* _UAPI__LINUX_BPF_COMMON_H__ */
diff --git a/include/uapi/linux/filter.h b/include/uapi/linux/filter.h
index 253b4d4..47785d5 100644
--- a/include/uapi/linux/filter.h
+++ b/include/uapi/linux/filter.h
@@ -7,7 +7,7 @@
 
 #include <linux/compiler.h>
 #include <linux/types.h>
-
+#include <linux/bpf_common.h>
 
 /*
  * Current version of the filter code architecture.
@@ -32,56 +32,6 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
 	struct sock_filter __user *filter;
 };
 
-/*
- * Instruction classes
- */
-
-#define BPF_CLASS(code) ((code) & 0x07)
-#define         BPF_LD          0x00
-#define         BPF_LDX         0x01
-#define         BPF_ST          0x02
-#define         BPF_STX         0x03
-#define         BPF_ALU         0x04
-#define         BPF_JMP         0x05
-#define         BPF_RET         0x06
-#define         BPF_MISC        0x07
-
-/* ld/ldx fields */
-#define BPF_SIZE(code)  ((code) & 0x18)
-#define         BPF_W           0x00
-#define         BPF_H           0x08
-#define         BPF_B           0x10
-#define BPF_MODE(code)  ((code) & 0xe0)
-#define         BPF_IMM         0x00
-#define         BPF_ABS         0x20
-#define         BPF_IND         0x40
-#define         BPF_MEM         0x60
-#define         BPF_LEN         0x80
-#define         BPF_MSH         0xa0
-
-/* alu/jmp fields */
-#define BPF_OP(code)    ((code) & 0xf0)
-#define         BPF_ADD         0x00
-#define         BPF_SUB         0x10
-#define         BPF_MUL         0x20
-#define         BPF_DIV         0x30
-#define         BPF_OR          0x40
-#define         BPF_AND         0x50
-#define         BPF_LSH         0x60
-#define         BPF_RSH         0x70
-#define         BPF_NEG         0x80
-#define		BPF_MOD		0x90
-#define		BPF_XOR		0xa0
-
-#define         BPF_JA          0x00
-#define         BPF_JEQ         0x10
-#define         BPF_JGT         0x20
-#define         BPF_JGE         0x30
-#define         BPF_JSET        0x40
-#define BPF_SRC(code)   ((code) & 0x08)
-#define         BPF_K           0x00
-#define         BPF_X           0x08
-
 /* ret - BPF_K and BPF_X also apply */
 #define BPF_RVAL(code)  ((code) & 0x18)
 #define         BPF_A           0x10
@@ -91,10 +41,6 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
 #define         BPF_TAX         0x00
 #define         BPF_TXA         0x80
 
-#ifndef BPF_MAXINSNS
-#define BPF_MAXINSNS 4096
-#endif
-
 /*
  * Macros for filter block array initializers.
  */
-- 
1.7.9.5
