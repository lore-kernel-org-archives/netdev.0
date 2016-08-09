From: Sargun Dhillon <sargun@sargun.me>
Subject: [net-next v2 v2 0/2] Add bpf current_task_in_cgroup helper &
 opensnoop example
Date: Tue, 9 Aug 2016 16:59:57 -0700
Message-ID: <20160809235955.GA28438@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:35799 "EHLO
	mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909AbcHJAAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 20:00:00 -0400
Received: by mail-it0-f42.google.com with SMTP id u186so26011521ita.0
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2016 17:00:00 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset includes a helper and an example to determine whether the probe is 
currently executing in the context of a specific cgroup based on a cgroup bpf 
map / array. The helper checks the cgroupsv2 hierarchy based on the handle in 
the map and if the current cgroup is equal to it, or a descendant of it. The 
helper was tested with the example program, and it was verified that the correct 
behaviour occurs in the interrupt context.

The example on the other hand, "open snoop" is much simplified version of that 
in the iovisor/BCC project. In order to run it, you must supply a specific 
cgroup in the hierarchy, and it'll print out all files being opened under it.

v1->v2: Add better example code -- OpenSnoop, clean up

	

Sargun Dhillon (2):
  bpf: Add bpf_current_task_in_cgroup helper
  samples/bpf: Add opensnoop example that uses current_task_in_cgroup
    helper

 include/linux/bpf.h                | 24 +++++++++++++
 include/uapi/linux/bpf.h           | 11 ++++++
 kernel/bpf/arraymap.c              |  2 +-
 kernel/bpf/verifier.c              |  4 ++-
 kernel/trace/bpf_trace.c           | 34 ++++++++++++++++++
 net/core/filter.c                  | 11 +++---
 samples/bpf/Makefile               |  4 +++
 samples/bpf/bpf_helpers.h          |  2 ++
 samples/bpf/trace_opensnoop_kern.c | 35 +++++++++++++++++++
 samples/bpf/trace_opensnoop_user.c | 70 ++++++++++++++++++++++++++++++++++++++
 10 files changed, 188 insertions(+), 9 deletions(-)
 create mode 100644 samples/bpf/trace_opensnoop_kern.c
 create mode 100644 samples/bpf/trace_opensnoop_user.c

-- 
2.7.4
