From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next] bpf: bpf_stackmap_copy depends on CONFIG_PERF_EVENTS
Date: Wed, 9 Mar 2016 18:56:49 -0800
Message-ID: <1457578609-277357-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Fengguang Wu <fengguang.wu@intel.com>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:49226 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753958AbcCJC4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 21:56:54 -0500
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.15.0.59/8.15.0.59) with SMTP id u2A2rWq8006451
	for <netdev@vger.kernel.org>; Wed, 9 Mar 2016 18:56:53 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 21jt8phjw1-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 18:56:53 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 bbd8c9f4e66b11e5a98b0002c99331b0-614e6420 for <netdev@vger.kernel.org>;	Wed,
 09 Mar 2016 18:56:49 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

0-day bot reported build error:
kernel/built-in.o: In function `map_lookup_elem':
>> kernel/bpf/.tmp_syscall.o:(.text+0x329b3c): undefined reference to `bpf_stackmap_copy'
when CONFIG_BPF_SYSCALL is set and CONFIG_PERF_EVENTS is not.
Add weak definition to resolve it.
This code path in map_lookup_elem() is never taken
when CONFIG_PERF_EVENTS is not set.

Fixes: 557c0c6e7df8 ("bpf: convert stackmap to pre-allocation")
Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/syscall.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 2978d0d08869..2a2efe1bc76c 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -244,6 +244,11 @@ static void __user *u64_to_ptr(__u64 val)
 	return (void __user *) (unsigned long) val;
 }
 
+int __weak bpf_stackmap_copy(struct bpf_map *map, void *key, void *value)
+{
+	return -ENOTSUPP;
+}
+
 /* last field in 'union bpf_attr' used by this command */
 #define BPF_MAP_LOOKUP_ELEM_LAST_FIELD value
 
-- 
2.8.0.rc1
