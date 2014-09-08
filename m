From: Ani Sinha <ani@arista.com>
Subject: [PATCH 1/1] net:socket: set msg_namelen to 0 if msg_name is passed as NULL in msghdr struct from userland.
Date: Mon,  8 Sep 2014 14:49:59 -0700
Message-ID: <1410212999-11013-1-git-send-email-ani@arista.com>
To: ani@arista.com, fruggeri@arista.com, davem@davemloft.net,
	netdev@vger.kernel.org, fenner@arista.com, travisb@arista.com,
	hannes@stressinduktion.org, matthew.leach@arm.com,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:57637 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754951AbaIHVub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 17:50:31 -0400
Received: by mail-pd0-f180.google.com with SMTP id ft15so5521991pdb.25
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 14:50:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linux manpage for recvmsg and sendmsg calls does not explicitly mention setting msg_namelen to 0 when
msg_name passed set as NULL. When developers don't set msg_namelen member in msghdr, it might contain garbage
value which will fail the validation check and sendmsg and recvmsg calls from kernel will return EINVAL. This will
break old binaries and any code for which there is no access to source code.
To fix this, we set msg_namelen to 0 when msg_name is passed as NULL from userland.

Signed-off-by: Ani Sinha <ani@arista.com>
---
 net/socket.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 95ee7d8..457be6a 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1997,6 +1997,9 @@ static int copy_msghdr_from_user(struct msghdr *kmsg,
 	if (copy_from_user(kmsg, umsg, sizeof(struct msghdr)))
 		return -EFAULT;
 
+	if (kmsg->msg_name == NULL)
+		kmsg->msg_namelen = 0;
+
 	if (kmsg->msg_namelen < 0)
 		return -EINVAL;
 
-- 
1.7.4.4
