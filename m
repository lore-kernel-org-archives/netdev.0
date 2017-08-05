From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: use __GFP_NOWARN for sctpw.fifo allocation
Date: Sat,  5 Aug 2017 20:31:09 +0800
Message-ID: <53b360387db05bf31db481234e7070e4a7ba6a25.1501936269.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35143 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751226AbdHEMbS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 08:31:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chen Wei found a kernel call trace when modprobe sctp_probe with
bufsize set with a huge value.

It's because in sctpprobe_init when alloc memory for sctpw.fifo,
the size is got from userspace. If it is too large, kernel will
fail and give a warning.

As there will be a fallback allocation later, this patch is just
to fail silently and return ret, just as commit 0ccc22f425e5
("sit: use __GFP_NOWARN for user controlled allocation") did.

Reported-by: Chen Wei <weichen@redhat.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/probe.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/probe.c b/net/sctp/probe.c
index 6cc2152..5bf3164 100644
--- a/net/sctp/probe.c
+++ b/net/sctp/probe.c
@@ -210,7 +210,7 @@ static __init int sctpprobe_init(void)
 
 	init_waitqueue_head(&sctpw.wait);
 	spin_lock_init(&sctpw.lock);
-	if (kfifo_alloc(&sctpw.fifo, bufsize, GFP_KERNEL))
+	if (kfifo_alloc(&sctpw.fifo, bufsize, GFP_KERNEL | __GFP_NOWARN))
 		return ret;
 
 	if (!proc_create(procname, S_IRUSR, init_net.proc_net,
-- 
2.1.0
