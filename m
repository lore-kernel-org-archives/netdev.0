From: Sargun Dhillon <sargun@sargun.me>
Subject: [PATCH net-next v5 0/2] bpf: add bpf_probe_write helper & example
Date: Sat, 23 Jul 2016 17:43:34 -0700
Message-ID: <20160724004332.GA31764@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:34646 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499AbcGXAng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jul 2016 20:43:36 -0400
Received: by mail-io0-f169.google.com with SMTP id q83so135032937iod.1
        for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 17:43:36 -0700 (PDT)
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
v4->v5:	Raise warning level
	Cleanup location of warning code
	Make test fail when helper is broken

Sargun Dhillon (2):
  bpf: Add bpf_probe_write_user BPF helper to be called in tracers
  samples/bpf: Add test/example of using bpf_probe_write_user bpf helper

 include/uapi/linux/bpf.h                 | 10 ++++
 kernel/trace/bpf_trace.c                 | 48 ++++++++++++++++++++
 samples/bpf/Makefile                     |  4 ++
 samples/bpf/bpf_helpers.h                |  2 +
 samples/bpf/test_probe_write_user_kern.c | 52 +++++++++++++++++++++
 samples/bpf/test_probe_write_user_user.c | 78 ++++++++++++++++++++++++++++++++
 6 files changed, 194 insertions(+)
 create mode 100644 samples/bpf/test_probe_write_user_kern.c
 create mode 100644 samples/bpf/test_probe_write_user_user.c

-- 
2.7.4
