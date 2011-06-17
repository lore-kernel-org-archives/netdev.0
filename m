From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] ss: fix autobound filter
Date: Fri, 17 Jun 2011 15:21:51 +0200
Message-ID: <1308316911.2780.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54170 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758984Ab1FQNVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 09:21:55 -0400
Received: by wyb38 with SMTP id 38so309479wyb.19
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2011 06:21:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes following error. We currently provide garbage data to kernel, that
can abort the validation process or produce unexpected results.

$ ss -a autobound
State      Recv-Q Send-Q      Local Address:Port          Peer Address:Port   
TCPDIAG answers: Invalid argument

After patch:

$ misc/ss -a autobound 
State      Recv-Q Send-Q      Local Address:Port          Peer Address:Port   
LISTEN     0      128                     *:44624                    *:*       
ESTAB      0      0            192.168.1.21:47141        74.125.79.109:imaps   

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 misc/ss.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index 482b6bb..4033e92 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -803,7 +803,7 @@ static int ssfilter_bytecompile(struct ssfilter *f, char **bytecode)
 	{
 		if (!(*bytecode=malloc(4))) abort();
 		((struct inet_diag_bc_op*)*bytecode)[0] = (struct inet_diag_bc_op){ INET_DIAG_BC_AUTO, 4, 8 };
-		return 8;
+		return 4;
 	}
 		case SSF_DCOND:
 		case SSF_SCOND:


