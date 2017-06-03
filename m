From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v4 net-next 3/3] bpf: update perf event helper functions documentation
Date: Fri, 2 Jun 2017 21:03:54 -0700
Message-ID: <20170603040354.3580555-4-ast@fb.com>
References: <20170603040354.3580555-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <peterz@infradead.org>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Teng Qin <qinteng@fb.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:40924 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750713AbdFCED4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Jun 2017 00:03:56 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v533xf0r003657
        for <netdev@vger.kernel.org>; Fri, 2 Jun 2017 21:03:55 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2aujrj08ps-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 02 Jun 2017 21:03:55 -0700
Received: from facebook.com (2401:db00:11:d082:face:0:5:0)      by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 a93aa174481111e7a9d60002c9dfb610-a5d358f0 for <netdev@vger.kernel.org>;        Fri,
 02 Jun 2017 21:03:54 -0700
In-Reply-To: <20170603040354.3580555-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Teng Qin <qinteng@fb.com>

This commit updates documentation of the bpf_perf_event_output and
bpf_perf_event_read helpers to match their implementation.

Signed-off-by: Teng Qin <qinteng@fb.com>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 include/uapi/linux/bpf.h       | 11 +++++++----
 tools/include/uapi/linux/bpf.h | 11 +++++++----
 2 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 94dfa9def355..e78aece03628 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -313,8 +313,11 @@ union bpf_attr {
  *     @flags: room for future extensions
  *     Return: 0 on success or negative error
  *
- * u64 bpf_perf_event_read(&map, index)
- *     Return: Number events read or error code
+ * u64 bpf_perf_event_read(map, flags)
+ *     read perf event counter value
+ *     @map: pointer to perf_event_array map
+ *     @flags: index of event in the map or bitmask flags
+ *     Return: value of perf event counter read or error code
  *
  * int bpf_redirect(ifindex, flags)
  *     redirect to another netdev
@@ -328,11 +331,11 @@ union bpf_attr {
  *     @skb: pointer to skb
  *     Return: realm if != 0
  *
- * int bpf_perf_event_output(ctx, map, index, data, size)
+ * int bpf_perf_event_output(ctx, map, flags, data, size)
  *     output perf raw sample
  *     @ctx: struct pt_regs*
  *     @map: pointer to perf_event_array map
- *     @index: index of event in the map
+ *     @flags: index of event in the map or bitmask flags
  *     @data: data on stack to be output as raw data
  *     @size: size of data
  *     Return: 0 on success or negative error
diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index 94dfa9def355..e78aece03628 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -313,8 +313,11 @@ union bpf_attr {
  *     @flags: room for future extensions
  *     Return: 0 on success or negative error
  *
- * u64 bpf_perf_event_read(&map, index)
- *     Return: Number events read or error code
+ * u64 bpf_perf_event_read(map, flags)
+ *     read perf event counter value
+ *     @map: pointer to perf_event_array map
+ *     @flags: index of event in the map or bitmask flags
+ *     Return: value of perf event counter read or error code
  *
  * int bpf_redirect(ifindex, flags)
  *     redirect to another netdev
@@ -328,11 +331,11 @@ union bpf_attr {
  *     @skb: pointer to skb
  *     Return: realm if != 0
  *
- * int bpf_perf_event_output(ctx, map, index, data, size)
+ * int bpf_perf_event_output(ctx, map, flags, data, size)
  *     output perf raw sample
  *     @ctx: struct pt_regs*
  *     @map: pointer to perf_event_array map
- *     @index: index of event in the map
+ *     @flags: index of event in the map or bitmask flags
  *     @data: data on stack to be output as raw data
  *     @size: size of data
  *     Return: 0 on success or negative error
-- 
2.9.3
