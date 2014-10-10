From: roy.qing.li@gmail.com
Subject: [PATCH][net-next][V2] net: filter: fix the comments
Date: Fri, 10 Oct 2014 13:56:51 +0800
Message-ID: <1412920611-2094-1-git-send-email-roy.qing.li@gmail.com>
Cc: ast@plumgrid.com, alexei.starovoitov@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:42461 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbaJJF46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 01:56:58 -0400
Received: by mail-pd0-f178.google.com with SMTP id y10so1016396pdj.23
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2014 22:56:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

1. sk_run_filter has been renamed, sk_filter() is using SK_RUN_FILTER.
2. Remove wrong comments about storing intermediate value.
3. replace sk_run_filter with __bpf_prog_run for check_load_and_stores's
comments

Cc: Alexei Starovoitov <ast@plumgrid.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/core/filter.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index fcd3f67..647b122 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -51,9 +51,9 @@
  *	@skb: buffer to filter
  *
  * Run the filter code and then cut skb->data to correct size returned by
- * sk_run_filter. If pkt_len is 0 we toss packet. If skb->len is smaller
+ * SK_RUN_FILTER. If pkt_len is 0 we toss packet. If skb->len is smaller
  * than pkt_len we keep whole skb->data. This is the socket level
- * wrapper to sk_run_filter. It returns 0 if the packet should
+ * wrapper to SK_RUN_FILTER. It returns 0 if the packet should
  * be accepted or -EPERM if the packet should be tossed.
  *
  */
@@ -566,11 +566,8 @@ err:
 
 /* Security:
  *
- * A BPF program is able to use 16 cells of memory to store intermediate
- * values (check u32 mem[BPF_MEMWORDS] in sk_run_filter()).
- *
  * As we dont want to clear mem[] array for each packet going through
- * sk_run_filter(), we check that filter loaded by user never try to read
+ * __bpf_prog_run(), we check that filter loaded by user never try to read
  * a cell if not previously written, and we check all branches to be sure
  * a malicious user doesn't try to abuse us.
  */
-- 
1.7.10.4
