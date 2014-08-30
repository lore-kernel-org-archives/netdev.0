From: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v8 net-next 2/2] net: filter: split filter.h and expose
 eBPF to user space
Date: Sat, 30 Aug 2014 09:48:49 +0200
Message-ID: <540181E1.8070702@redhat.com>
References: <1409171833-6979-1-git-send-email-ast@plumgrid.com> <1409171833-6979-3-git-send-email-ast@plumgrid.com> <5400BAB7.80001@redhat.com> <CAADnVQJbgiUK1vt_SDEG6Yee-Ht67e2M82PrHb3Kx533BOF-rg@mail.gmail.com> <5400FDA0.7000704@redhat.com> <CAMEtUuyRUujYhRsH9aUx0h7wvU1DrKRHNWZtoOYEgHVfKdCTxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080406010806070805050502"
Cc: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Brendan Gregg <brendan.d.gregg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMEtUuyRUujYhRsH9aUx0h7wvU1DrKRHNWZtoOYEgHVfKdCTxw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080406010806070805050502
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 08/30/2014 01:01 AM, Alexei Starovoitov wrote:
...
> imo it's a consistency issue. If main uapi header is ebpf.h then
> corresponding kernel internal header should be ebpf.h as well
> and kernel/ebpf/ directory and so on.

I don't think that has to be enforced, but fair enough, if you
feel that way.

> That's why I insist on uapi/linux/bpf.h and no other name.
...
> them into bpf_common.h. My request is let's not fight about it
> right now. We didn't even cross the bridge yet and arguing
> about beauty of user apps that come in 30 patches from now...
...
> So these two patches are mainly establishing _intent_ and bpf.h file
> name. That's why I'm so paranoid about naming.

I understand, and that's why I said it could also be resolved later
in my previous email (at latest before it gets shipped though), but
just to give this some thought ...

I have attached one example, it doesn't have to be that way, but it's
one possibility if you want to stay with linux/bpf.h only.

--------------080406010806070805050502
Content-Type: text/x-patch;
 name="0001-net-filter-split-filter.h-and-expose-eBPF-to-user-sp.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-net-filter-split-filter.h-and-expose-eBPF-to-user-sp.pa";
 filename*1="tch"

>From b359aeec95b81262f352f7613178949b94b9a097 Mon Sep 17 00:00:00 2001
From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Date: Wed, 27 Aug 2014 13:37:13 -0700
Subject: [PATCH] net: filter: split filter.h and expose eBPF to user space

Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
---
 include/linux/filter.h      |  57 +-------------
 include/uapi/linux/Kbuild   |   1 +
 include/uapi/linux/bpf.h    | 179 ++++++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/filter.h | 142 ++---------------------------------
 4 files changed, 186 insertions(+), 193 deletions(-)
 create mode 100644 include/uapi/linux/bpf.h

diff --git a/include/linux/filter.h b/include/linux/filter.h
index f3262b5..f2dd63a 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -8,54 +8,7 @@
 #include <linux/compat.h>
 #include <linux/skbuff.h>
 #include <linux/workqueue.h>
-#include <uapi/linux/filter.h>
-
-/* Internally used and optimized filter representation with extended
- * instruction set based on top of classic BPF.
- */
-
-/* instruction classes */
-#define BPF_ALU64	0x07	/* alu mode in double word width */
-
-/* ld/ldx fields */
-#define BPF_DW		0x18	/* double word */
-#define BPF_XADD	0xc0	/* exclusive add */
-
-/* alu/jmp fields */
-#define BPF_MOV		0xb0	/* mov reg to reg */
-#define BPF_ARSH	0xc0	/* sign extending arithmetic shift right */
-
-/* change endianness of a register */
-#define BPF_END		0xd0	/* flags for endianness conversion: */
-#define BPF_TO_LE	0x00	/* convert to little-endian */
-#define BPF_TO_BE	0x08	/* convert to big-endian */
-#define BPF_FROM_LE	BPF_TO_LE
-#define BPF_FROM_BE	BPF_TO_BE
-
-#define BPF_JNE		0x50	/* jump != */
-#define BPF_JSGT	0x60	/* SGT is signed '>', GT in x86 */
-#define BPF_JSGE	0x70	/* SGE is signed '>=', GE in x86 */
-#define BPF_CALL	0x80	/* function call */
-#define BPF_EXIT	0x90	/* function return */
-
-/* Register numbers */
-enum {
-	BPF_REG_0 = 0,
-	BPF_REG_1,
-	BPF_REG_2,
-	BPF_REG_3,
-	BPF_REG_4,
-	BPF_REG_5,
-	BPF_REG_6,
-	BPF_REG_7,
-	BPF_REG_8,
-	BPF_REG_9,
-	BPF_REG_10,
-	__MAX_BPF_REG,
-};
-
-/* BPF has 10 general purpose 64-bit registers and stack frame. */
-#define MAX_BPF_REG	__MAX_BPF_REG
+#include <uapi/linux/bpf.h>
 
 /* ArgX, context and stack frame pointer register positions. Note,
  * Arg1, Arg2, Arg3, etc are used as argument mappings of function
@@ -317,14 +270,6 @@ enum {
 #define SK_RUN_FILTER(filter, ctx) \
 	(*filter->prog->bpf_func)(ctx, filter->prog->insnsi)
 
-struct bpf_insn {
-	__u8	code;		/* opcode */
-	__u8	dst_reg:4;	/* dest register */
-	__u8	src_reg:4;	/* source register */
-	__s16	off;		/* signed offset */
-	__s32	imm;		/* signed immediate constant */
-};
-
 #ifdef CONFIG_COMPAT
 /* A struct sock_filter is architecture independent. */
 struct compat_sock_fprog {
diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index 24e9033..fb3f7b6 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -67,6 +67,7 @@ header-y += bfs_fs.h
 header-y += binfmts.h
 header-y += blkpg.h
 header-y += blktrace_api.h
+header-y += bpf.h
 header-y += bpqether.h
 header-y += bsg.h
 header-y += btrfs.h
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
new file mode 100644
index 0000000..76138c2
--- /dev/null
+++ b/include/uapi/linux/bpf.h
@@ -0,0 +1,179 @@
+#ifndef __UAPI_BPF_H
+#define __UAPI_BPF_H
+
+#include <linux/compiler.h>
+#include <linux/types.h>
+
+/* Current version of the filter code architecture. */
+#define BPF_MAJOR_VERSION 1
+#define BPF_MINOR_VERSION 1
+
+/* Try and keep these values and structures similar to BSD,
+ * especially the BPF code definitions which need to match
+ * so you can share filters.
+ */
+struct sock_filter {	/* Filter block */
+	__u16	code;	/* Actual filter code */
+	__u8	jt;	/* Jump true */
+	__u8	jf;	/* Jump false */
+	__u32	k;	/* Generic multiuse field */
+};
+
+struct sock_fprog {			/* Required for SO_ATTACH_FILTER. */
+	unsigned short		len;	/* Number of filter blocks */
+	struct sock_filter __user *filter;
+};
+
+/* Instruction classes */
+#define BPF_CLASS(code) ((code) & 0x07)
+#define  BPF_LD			  0x00
+#define  BPF_LDX		  0x01
+#define  BPF_ST			  0x02
+#define  BPF_STX		  0x03
+#define  BPF_ALU		  0x04
+#define  BPF_JMP		  0x05
+#define  BPF_RET		  0x06
+#define  BPF_MISC		  0x07
+
+/* ld/ldx fields */
+#define BPF_SIZE(code)  ((code) & 0x18)
+#define  BPF_W			  0x00
+#define  BPF_H			  0x08
+#define  BPF_B			  0x10
+#define BPF_MODE(code)  ((code) & 0xe0)
+#define  BPF_IMM		  0x00
+#define  BPF_ABS		  0x20
+#define  BPF_IND		  0x40
+#define  BPF_MEM		  0x60
+#define  BPF_LEN		  0x80
+#define  BPF_MSH		  0xa0
+
+/* alu/jmp fields */
+#define BPF_OP(code)    ((code) & 0xf0)
+#define  BPF_ADD		  0x00
+#define  BPF_SUB		  0x10
+#define  BPF_MUL		  0x20
+#define  BPF_DIV		  0x30
+#define  BPF_OR			  0x40
+#define  BPF_AND		  0x50
+#define  BPF_LSH		  0x60
+#define  BPF_RSH		  0x70
+#define  BPF_NEG		  0x80
+#define  BPF_MOD		  0x90
+#define  BPF_XOR		  0xa0
+
+#define  BPF_JA			  0x00
+#define  BPF_JEQ		  0x10
+#define  BPF_JGT		  0x20
+#define  BPF_JGE		  0x30
+#define  BPF_JSET		  0x40
+#define BPF_SRC(code)   ((code) & 0x08)
+#define  BPF_K			  0x00
+#define  BPF_X			  0x08
+
+/* ret - BPF_K and BPF_X also apply */
+#define BPF_RVAL(code)  ((code) & 0x18)
+#define  BPF_A			  0x10
+
+/* misc */
+#define BPF_MISCOP(code) ((code) & 0xf8)
+#define  BPF_TAX		   0x00
+#define  BPF_TXA		   0x80
+
+#ifndef __WITHOUT_EBPF
+/* Extended instruction set based on top of classic BPF */
+
+/* Instruction classes */
+#define BPF_ALU64	0x07	/* ALU mode in double word width */
+
+/* ld/ldx fields */
+#define BPF_DW		0x18	/* Double word */
+#define BPF_XADD	0xc0	/* Exclusive add */
+
+/* alu/jmp fields */
+#define BPF_MOV		0xb0	/* mov reg to reg */
+#define BPF_ARSH	0xc0	/* Sign extending arithmetic shift right */
+
+/* Change endianness of a register */
+#define BPF_END		0xd0	/* Flags for endianness conversion: */
+#define BPF_TO_LE	0x00	/* Convert to little-endian */
+#define BPF_TO_BE	0x08	/* Convert to big-endian */
+#define BPF_FROM_LE	BPF_TO_LE
+#define BPF_FROM_BE	BPF_TO_BE
+
+#define BPF_JNE		0x50	/* jump != */
+#define BPF_JSGT	0x60	/* SGT is signed '>', GT in x86 */
+#define BPF_JSGE	0x70	/* SGE is signed '>=', GE in x86 */
+#define BPF_CALL	0x80	/* Function call */
+#define BPF_EXIT	0x90	/* Function return */
+
+/* Register numbers */
+enum {
+	BPF_REG_0 = 0,
+	BPF_REG_1,
+	BPF_REG_2,
+	BPF_REG_3,
+	BPF_REG_4,
+	BPF_REG_5,
+	BPF_REG_6,
+	BPF_REG_7,
+	BPF_REG_8,
+	BPF_REG_9,
+	BPF_REG_10,
+	__MAX_BPF_REG,
+};
+
+/* BPF has 10 general purpose 64-bit registers and stack frame. */
+#define MAX_BPF_REG	__MAX_BPF_REG
+
+struct bpf_insn {
+	__u8	code;		/* Opcode */
+	__u8	dst_reg:4;	/* Dest register */
+	__u8	src_reg:4;	/* Source register */
+	__s16	off;		/* Signed offset */
+	__s32	imm;		/* Signed immediate constant */
+};
+
+#endif /* __WITHOUT_EBPF */
+
+#ifndef BPF_MAXINSNS
+# define BPF_MAXINSNS	4096
+#endif
+
+/* Macros for filter block array initializers. */
+#ifndef BPF_STMT
+# define BPF_STMT(code, k) { (unsigned short)(code), 0, 0, k }
+#endif
+#ifndef BPF_JUMP
+# define BPF_JUMP(code, k, jt, jf) { (unsigned short)(code), jt, jf, k }
+#endif
+
+/* Number of scratch memory words for: BPF_ST and BPF_STX */
+#define BPF_MEMWORDS 16
+
+/* Rationale: Negative offsets are invalid in BPF. We use
+ * them to reference ancillary data. Unlike introduction new
+ * instructions, it does not break existing compilers /
+ * optimizers.
+ */
+#define SKF_AD_OFF		(-0x1000)
+#define SKF_AD_PROTOCOL		0
+#define SKF_AD_PKTTYPE		4
+#define SKF_AD_IFINDEX		8
+#define SKF_AD_NLATTR		12
+#define SKF_AD_NLATTR_NEST	16
+#define SKF_AD_MARK		20
+#define SKF_AD_QUEUE		24
+#define SKF_AD_HATYPE		28
+#define SKF_AD_RXHASH		32
+#define SKF_AD_CPU		36
+#define SKF_AD_ALU_XOR_X	40
+#define SKF_AD_VLAN_TAG		44
+#define SKF_AD_VLAN_TAG_PRESENT	48
+#define SKF_AD_PAY_OFFSET	52
+#define SKF_AD_RANDOM		56
+#define SKF_AD_MAX		60
+#define SKF_NET_OFF		(-0x100000)
+#define SKF_LL_OFF		(-0x200000)
+
+#endif /* __UAPI_BPF_H */
diff --git a/include/uapi/linux/filter.h b/include/uapi/linux/filter.h
index 253b4d4..f7207bd 100644
--- a/include/uapi/linux/filter.h
+++ b/include/uapi/linux/filter.h
@@ -1,139 +1,7 @@
-/*
- * Linux Socket Filter Data Structures
- */
+#ifndef __UAPI_FILTER_H
+#define __UAPI_FILTER_H
 
-#ifndef _UAPI__LINUX_FILTER_H__
-#define _UAPI__LINUX_FILTER_H__
+#define __WITHOUT_EBPF
+#include <linux/bpf.h>
 
-#include <linux/compiler.h>
-#include <linux/types.h>
-
-
-/*
- * Current version of the filter code architecture.
- */
-#define BPF_MAJOR_VERSION 1
-#define BPF_MINOR_VERSION 1
-
-/*
- *	Try and keep these values and structures similar to BSD, especially
- *	the BPF code definitions which need to match so you can share filters
- */
- 
-struct sock_filter {	/* Filter block */
-	__u16	code;   /* Actual filter code */
-	__u8	jt;	/* Jump true */
-	__u8	jf;	/* Jump false */
-	__u32	k;      /* Generic multiuse field */
-};
-
-struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
-	unsigned short		len;	/* Number of filter blocks */
-	struct sock_filter __user *filter;
-};
-
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
-/* ret - BPF_K and BPF_X also apply */
-#define BPF_RVAL(code)  ((code) & 0x18)
-#define         BPF_A           0x10
-
-/* misc */
-#define BPF_MISCOP(code) ((code) & 0xf8)
-#define         BPF_TAX         0x00
-#define         BPF_TXA         0x80
-
-#ifndef BPF_MAXINSNS
-#define BPF_MAXINSNS 4096
-#endif
-
-/*
- * Macros for filter block array initializers.
- */
-#ifndef BPF_STMT
-#define BPF_STMT(code, k) { (unsigned short)(code), 0, 0, k }
-#endif
-#ifndef BPF_JUMP
-#define BPF_JUMP(code, k, jt, jf) { (unsigned short)(code), jt, jf, k }
-#endif
-
-/*
- * Number of scratch memory words for: BPF_ST and BPF_STX
- */
-#define BPF_MEMWORDS 16
-
-/* RATIONALE. Negative offsets are invalid in BPF.
-   We use them to reference ancillary data.
-   Unlike introduction new instructions, it does not break
-   existing compilers/optimizers.
- */
-#define SKF_AD_OFF    (-0x1000)
-#define SKF_AD_PROTOCOL 0
-#define SKF_AD_PKTTYPE 	4
-#define SKF_AD_IFINDEX 	8
-#define SKF_AD_NLATTR	12
-#define SKF_AD_NLATTR_NEST	16
-#define SKF_AD_MARK 	20
-#define SKF_AD_QUEUE	24
-#define SKF_AD_HATYPE	28
-#define SKF_AD_RXHASH	32
-#define SKF_AD_CPU	36
-#define SKF_AD_ALU_XOR_X	40
-#define SKF_AD_VLAN_TAG	44
-#define SKF_AD_VLAN_TAG_PRESENT 48
-#define SKF_AD_PAY_OFFSET	52
-#define SKF_AD_RANDOM	56
-#define SKF_AD_MAX	60
-#define SKF_NET_OFF   (-0x100000)
-#define SKF_LL_OFF    (-0x200000)
-
-
-#endif /* _UAPI__LINUX_FILTER_H__ */
+#endif /* __UAPI_FILTER_H */
-- 
1.7.11.7


--------------080406010806070805050502--
