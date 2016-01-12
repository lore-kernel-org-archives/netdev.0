From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v2 net-next 0/4] bpf: bpf_htab: Add BPF_MAP_TYPE_PERCPU_HASH
Date: Tue, 12 Jan 2016 00:20:48 -0800
Message-ID: <1452586852-1575604-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Ming Lei <tom.leiming@gmail.com>,
	FB Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

V2:
Patch 1/4:
* Remove flush_elems_fn from 'struct bpf_htab' and
  also remove htab_map_flush() together
* Add htab_elem_alloc()
* Move the l_old check from htab_map_update_elem() to
  the newly added htab_map_check_update()

Patch 2/4:
* Add htab_percpu_elem_alloc()
* Add htab_percpu_map_free()
* Use this_cpu_ptr() instead of per_cpu_ptr in
  htab_percpu_map_lookup_elem()

V1 compose:
This patchset adds BPF_MAP_TYPE_PERCPU_HASH map type which allows
percpu value.

BPF + kprobe is very useful in statistics collection.  In particular,
bpf is strong in doing aggregation within the kernel instead of
outputting a lot of raw samples to the userspace.

In some cases, bumping a counter/value of a particular key will have
noticeable impact.  For example, doing statistics collection
on received packets and aggregating them by network
prefix (like /64 in IPv6).  Having a percpu value can help.
