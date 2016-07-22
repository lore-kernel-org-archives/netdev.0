From: Sargun Dhillon <sargun@sargun.me>
Subject: [PATCH v4 0/2] bpf: add bpf_probe_write helper & example
Date: Thu, 21 Jul 2016 18:08:59 -0700
Message-ID: <20160722010856.GA22966@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f48.google.com ([209.85.214.48]:37636 "EHLO
	mail-it0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752814AbcGVBJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 21:09:02 -0400
Received: by mail-it0-f48.google.com with SMTP id f6so33431063ith.0
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 18:09:01 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series contains two patches that add support for a probe_write
helper to BPF programs. This allows them to manipulate user memory during
the course of tracing. The second patch in the series has an example that
uses it, in one the intended ways to divert execution.

Thanks to Alexei Starovoitov, and Daniel Borkmann for review, I've made 
changes based on their recommendations.

This helper should be considered experimental, so we print a warning
to dmesg when it is first invoked. Subsequent invocations print the 
command and pid

---
v1->v2: restrict writing to user space, as opposed to globally
v2->v3: Fixed formatting issues
v3->v4: Rename copy_to_user -> bpf_probe_write
	Simplify checking of whether or not it's safe to write
	Add warnings to dmesg

Sargun Dhillon (2):
  bpf: Add bpf_probe_write BPF helper to be called in tracers (kprobes)
  samples/bpf: Add example of using bpf_probe_write in bpf kprobes

 include/uapi/linux/bpf.h   | 12 ++++++++
 kernel/bpf/verifier.c      |  9 ++++++
 kernel/trace/bpf_trace.c   | 37 +++++++++++++++++++++++
 samples/bpf/Makefile       |  4 +++
 samples/bpf/bpf_helpers.h  |  2 ++
 samples/bpf/tracex7_kern.c | 51 +++++++++++++++++++++++++++++++
 samples/bpf/tracex7_user.c | 75 ++++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 190 insertions(+)
 create mode 100644 samples/bpf/tracex7_kern.c
 create mode 100644 samples/bpf/tracex7_user.c

-- 
2.7.4
