From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Subject: [PATCH] silence warnings when building kernel/bpf/core.c with W=1
Date: Sun, 31 Jul 2016 23:27:33 -0400
Message-ID: <8434.1470022053@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound.smtp.vt.edu ([198.82.183.121]:44960 "EHLO
	omr1.cc.vt.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751513AbcHAD1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jul 2016 23:27:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Building with W=1 generates some 350 lines of warnings of the form:

kernel/bpf/core.c: In function '__bpf_prog_run':
kernel/bpf/core.c:476:33: warning: initialized field overwritten [-Woverride-init]
   [BPF_ALU | BPF_ADD | BPF_X] = &&ALU_ADD_X,
                                 ^~
kernel/bpf/core.c:476:33: note: (near initialization for 'jumptable[12]')

Since they come from the way we intentionally build the table, silence
that one specific warning.

Signed-off-by: Valdis Kletnieks <valdis.kletnieks@vt.edu>

diff --git a/kernel/bpf/Makefile b/kernel/bpf/Makefile
index eed911d091da..bb915f9d9f92 100644
--- a/kernel/bpf/Makefile
+++ b/kernel/bpf/Makefile
@@ -1,3 +1,4 @@
+CFLAGS_core.o += -Wno-override-init
 obj-y := core.o
 
 obj-$(CONFIG_BPF_SYSCALL) += syscall.o verifier.o inode.o helpers.o
