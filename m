From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next 5/5] bpf: create samples/bpf/tcp_bpf.readme
Date: Fri, 20 Oct 2017 11:05:43 -0700
Message-ID: <20171020180543.4156833-6-brakmo@fb.com>
References: <20171020180543.4156833-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Blake Matheny <bmatheny@fb.com>,
        Lawrence Brakmo <brakmo@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:58038 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753223AbdJTSF7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 14:05:59 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9KI4WcJ005137
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 11:05:59 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2dqmbgrd2d-6
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 11:05:59 -0700
In-Reply-To: <20171020180543.4156833-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Readme file explaining how to create a cgroupv2 and attach one
of the tcp_*_kern.o socket_ops BPF program.

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked_by: Alexei Starovoitov <ast@fb.com>
---
 samples/bpf/tcp_bbf.readme | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)
 create mode 100644 samples/bpf/tcp_bbf.readme

diff --git a/samples/bpf/tcp_bbf.readme b/samples/bpf/tcp_bbf.readme
new file mode 100644
index 0000000..3692056
--- /dev/null
+++ b/samples/bpf/tcp_bbf.readme
@@ -0,0 +1,27 @@
+This file describes how to run the tcp_*_kern.o tcp_bpf (or socket_ops)
+programs. These programs attach to a cgroupv2. The following commands create
+a cgroupv2 and attach a bash shell to the group.
+
+  mkdir -p /tmp/cgroupv2
+  mount -t cgroup2 none /tmp/cgroupv2
+  mkdir -p /tmp/cgroupv2/foo
+  bash
+  echo $$ >> /tmp/cgroupv2/foo/cgroup.procs
+
+Anything that runs under this shell belongs to the foo cgroupv2 To load
+(attach) one of the tcp_*_kern.o programs:
+
+  ./load_sock_ops -l /tmp/cgroupv2/foo tcp_basertt_kern.o
+
+If the "-l" flag is used, the load_sock_ops program will continue to run
+printing the BPF log buffer. The tcp_*_kern.o programs use special print
+functions to print logging information (if enabled by the ifdef).
+
+If using netperf/netserver to create traffic, you need to run them under the
+cgroupv2 to which the BPF programs are attached (i.e. under bash shell
+attached to the cgroupv2).
+
+To remove (unattach) a socket_ops BPF program from a cgroupv2:
+
+  ./load_sock_ops -r /tmp/cgroupv2/foo
+
-- 
2.9.5
