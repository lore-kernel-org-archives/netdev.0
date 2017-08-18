From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf, doc: improve sysctl knob description
Date: Fri, 18 Aug 2017 17:11:06 +0200
Message-ID: <5590c8b2426b46f038184153918663019c3bc7c7.1503068601.git.daniel@iogearbox.net>
Cc: ast@fb.com, mpe@ellerman.id.au, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53091 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751037AbdHRPLS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 11:11:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current context speaking of tcpdump filters is out of date these
days, so lets improve the sysctl description for the BPF knobs
a bit.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 [ Given Michael's arch list update went to net, here's the
   follow-up for improving the description as mentioned. ]

 Documentation/sysctl/net.txt | 37 +++++++++++++++++++++++--------------
 1 file changed, 23 insertions(+), 14 deletions(-)

diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/net.txt
index b9c3c60..d7c2b88 100644
--- a/Documentation/sysctl/net.txt
+++ b/Documentation/sysctl/net.txt
@@ -35,23 +35,32 @@ Table : Subdirectories in /proc/sys/net
 bpf_jit_enable
 --------------
 
-This enables Berkeley Packet Filter Just in Time compiler.
-
-There are two flavors of JIT, the new eBPF JIT supported on:
+This enables the BPF Just in Time (JIT) compiler. BPF is a flexible
+and efficient infrastructure allowing to execute bytecode at various
+hook points. It is used in a number of Linux kernel subsystems such
+as networking (e.g. XDP, tc), tracing (e.g. kprobes, uprobes, tracepoints)
+and security (e.g. seccomp). LLVM has a BPF back end that can compile
+restricted C into a sequence of BPF instructions. After program load
+through bpf(2) and passing a verifier in the kernel, a JIT will then
+translate these BPF proglets into native CPU instructions. There are
+two flavors of JITs, the newer eBPF JIT currently supported on:
   - x86_64
   - arm64
   - ppc64
   - sparc64
   - mips64
 
-And the older cBPF JIT supported on:
+And the older cBPF JIT supported on the following archs:
   - arm
   - mips
   - ppc
   - sparc
 
-The BPF JIT provides a framework to speed packet filtering, the one used by
-tcpdump/libpcap for example.
+eBPF JITs are a superset of cBPF JITs, meaning the kernel will
+migrate cBPF instructions into eBPF instructions and then JIT
+compile them transparently. Older cBPF JITs can only translate
+tcpdump filters, seccomp rules, etc, but not mentioned eBPF
+programs loaded through bpf(2).
 
 Values :
 	0 - disable the JIT (default value)
@@ -61,9 +70,9 @@ Values :
 bpf_jit_harden
 --------------
 
-This enables hardening for the Berkeley Packet Filter Just in Time compiler.
-Supported are eBPF JIT backends. Enabling hardening trades off performance,
-but can mitigate JIT spraying.
+This enables hardening for the BPF JIT compiler. Supported are eBPF
+JIT backends. Enabling hardening trades off performance, but can
+mitigate JIT spraying.
 Values :
 	0 - disable JIT hardening (default value)
 	1 - enable JIT hardening for unprivileged users only
@@ -72,11 +81,11 @@ Values :
 bpf_jit_kallsyms
 ----------------
 
-When Berkeley Packet Filter Just in Time compiler is enabled, then compiled
-images are unknown addresses to the kernel, meaning they neither show up in
-traces nor in /proc/kallsyms. This enables export of these addresses, which
-can be used for debugging/tracing. If bpf_jit_harden is enabled, this feature
-is disabled.
+When BPF JIT compiler is enabled, then compiled images are unknown
+addresses to the kernel, meaning they neither show up in traces nor
+in /proc/kallsyms. This enables export of these addresses, which can
+be used for debugging/tracing. If bpf_jit_harden is enabled, this
+feature is disabled.
 Values :
 	0 - disable JIT kallsyms export (default value)
 	1 - enable JIT kallsyms export for privileged users only
-- 
1.9.3
