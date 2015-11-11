From: Kamal Mostafa <kamal@canonical.com>
Subject: [PATCH] tools/net: Use include/uapi with __EXPORTED_HEADERS__
Date: Wed, 11 Nov 2015 14:24:27 -0800
Message-ID: <1447280667-1145-1-git-send-email-kamal@canonical.com>
Cc: Kamal Mostafa <kamal@canonical.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the local uapi headers to keep in sync with "recently" added #define's
(e.g. SKF_AD_VLAN_TPID).  Refactored CFLAGS, and bpf_asm doesn't need -I.

Fixes: 3f356385e8a449e1d7cfc6b6f8d634ac4f5581a0
Signed-off-by: Kamal Mostafa <kamal@canonical.com>
---
 tools/net/Makefile | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/tools/net/Makefile b/tools/net/Makefile
index ee577ea..ddf8880 100644
--- a/tools/net/Makefile
+++ b/tools/net/Makefile
@@ -4,6 +4,9 @@ CC = gcc
 LEX = flex
 YACC = bison
 
+CFLAGS += -Wall -O2
+CFLAGS += -D__EXPORTED_HEADERS__ -I../../include/uapi -I../../include
+
 %.yacc.c: %.y
 	$(YACC) -o $@ -d $<
 
@@ -12,15 +15,13 @@ YACC = bison
 
 all : bpf_jit_disasm bpf_dbg bpf_asm
 
-bpf_jit_disasm : CFLAGS = -Wall -O2 -DPACKAGE='bpf_jit_disasm'
+bpf_jit_disasm : CFLAGS += -DPACKAGE='bpf_jit_disasm'
 bpf_jit_disasm : LDLIBS = -lopcodes -lbfd -ldl
 bpf_jit_disasm : bpf_jit_disasm.o
 
-bpf_dbg : CFLAGS = -Wall -O2
 bpf_dbg : LDLIBS = -lreadline
 bpf_dbg : bpf_dbg.o
 
-bpf_asm : CFLAGS = -Wall -O2 -I.
 bpf_asm : LDLIBS =
 bpf_asm : bpf_asm.o bpf_exp.yacc.o bpf_exp.lex.o
 bpf_exp.lex.o : bpf_exp.yacc.c
-- 
1.9.1
