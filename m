From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Subject: [PATCH v2] bpf: silence warnings when building kernel/bpf/core.c with W=1
Date: Mon, 01 Aug 2016 00:33:30 -0400
Message-ID: <23710.1470026010@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound.smtp.vt.edu ([198.82.183.121]:51594 "EHLO
	omr1.cc.vt.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750883AbcHAEeu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2016 00:34:50 -0400
Content-ID: <23709.1470026010.1@turing-police.cc.vt.edu>
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

Version 2: Add bpf: subsystem tag to subject line

diff --git a/kernel/bpf/Makefile b/kernel/bpf/Makefile
index eed911d091da..bb915f9d9f92 100644
--- a/kernel/bpf/Makefile
+++ b/kernel/bpf/Makefile
@@ -1,3 +1,4 @@
+CFLAGS_core.o += -Wno-override-init
 obj-y := core.o
 
 obj-$(CONFIG_BPF_SYSCALL) += syscall.o verifier.o inode.o helpers.o
