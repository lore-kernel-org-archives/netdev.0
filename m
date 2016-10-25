From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf: fix samples to add fake KBUILD_MODNAME
Date: Wed, 26 Oct 2016 00:37:53 +0200
Message-ID: <1fdac65566ed6e0cff486507c5019f45807d1e89.1477434641.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41014 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752511AbcJYWiG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 18:38:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some of the sample files are causing issues when they are loaded with tc
and cls_bpf, meaning tc bails out while trying to parse the resulting ELF
file as program/map/etc sections are not present, which can be easily
spotted with readelf(1).

Currently, BPF samples are including some of the kernel headers and mid
term we should change them to refrain from this, really. When dynamic
debugging is enabled, we bail out due to undeclared KBUILD_MODNAME, which
is easily overlooked in the build as clang spills this along with other
noisy warnings from various header includes, and llc still generates an
ELF file with mentioned characteristics. For just playing around with BPF
examples, this can be a bit of a hurdle to take.

Just add a fake KBUILD_MODNAME as a band-aid to fix the issue, same is
done in xdp*_kern samples already.

Fixes: 65d472fb007d ("samples/bpf: add 'pointer to packet' tests")
Fixes: 6afb1e28b859 ("samples/bpf: Add tunnel set/get tests.")
Fixes: a3f74617340b ("cgroup: bpf: Add an example to do cgroup checking in BPF")
Reported-by: Chandrasekar Kannan <ckannan@console.to>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 samples/bpf/parse_ldabs.c        | 1 +
 samples/bpf/parse_simple.c       | 1 +
 samples/bpf/parse_varlen.c       | 1 +
 samples/bpf/tcbpf1_kern.c        | 1 +
 samples/bpf/tcbpf2_kern.c        | 1 +
 samples/bpf/test_cgrp2_tc_kern.c | 1 +
 6 files changed, 6 insertions(+)

diff --git a/samples/bpf/parse_ldabs.c b/samples/bpf/parse_ldabs.c
index d175501..6db6b21 100644
--- a/samples/bpf/parse_ldabs.c
+++ b/samples/bpf/parse_ldabs.c
@@ -4,6 +4,7 @@
  * modify it under the terms of version 2 of the GNU General Public
  * License as published by the Free Software Foundation.
  */
+#define KBUILD_MODNAME "foo"
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/in.h>
diff --git a/samples/bpf/parse_simple.c b/samples/bpf/parse_simple.c
index cf2511c..10af53d 100644
--- a/samples/bpf/parse_simple.c
+++ b/samples/bpf/parse_simple.c
@@ -4,6 +4,7 @@
  * modify it under the terms of version 2 of the GNU General Public
  * License as published by the Free Software Foundation.
  */
+#define KBUILD_MODNAME "foo"
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/in.h>
diff --git a/samples/bpf/parse_varlen.c b/samples/bpf/parse_varlen.c
index edab34d..95c1632 100644
--- a/samples/bpf/parse_varlen.c
+++ b/samples/bpf/parse_varlen.c
@@ -4,6 +4,7 @@
  * modify it under the terms of version 2 of the GNU General Public
  * License as published by the Free Software Foundation.
  */
+#define KBUILD_MODNAME "foo"
 #include <linux/if_ether.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
diff --git a/samples/bpf/tcbpf1_kern.c b/samples/bpf/tcbpf1_kern.c
index fa051b3..274c884 100644
--- a/samples/bpf/tcbpf1_kern.c
+++ b/samples/bpf/tcbpf1_kern.c
@@ -1,3 +1,4 @@
+#define KBUILD_MODNAME "foo"
 #include <uapi/linux/bpf.h>
 #include <uapi/linux/if_ether.h>
 #include <uapi/linux/if_packet.h>
diff --git a/samples/bpf/tcbpf2_kern.c b/samples/bpf/tcbpf2_kern.c
index 3303bb8..9c823a6 100644
--- a/samples/bpf/tcbpf2_kern.c
+++ b/samples/bpf/tcbpf2_kern.c
@@ -5,6 +5,7 @@
  * modify it under the terms of version 2 of the GNU General Public
  * License as published by the Free Software Foundation.
  */
+#define KBUILD_MODNAME "foo"
 #include <uapi/linux/bpf.h>
 #include <uapi/linux/if_ether.h>
 #include <uapi/linux/if_packet.h>
diff --git a/samples/bpf/test_cgrp2_tc_kern.c b/samples/bpf/test_cgrp2_tc_kern.c
index 10ff734..1547b36 100644
--- a/samples/bpf/test_cgrp2_tc_kern.c
+++ b/samples/bpf/test_cgrp2_tc_kern.c
@@ -4,6 +4,7 @@
  * modify it under the terms of version 2 of the GNU General Public
  * License as published by the Free Software Foundation.
  */
+#define KBUILD_MODNAME "foo"
 #include <uapi/linux/if_ether.h>
 #include <uapi/linux/in6.h>
 #include <uapi/linux/ipv6.h>
-- 
1.9.3
