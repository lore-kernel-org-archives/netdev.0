From: Andy Zhou <azhou@nicira.com>
Subject: [net-next 1/2] net: fix a sparse warning
Date: Mon,  6 Oct 2014 13:22:50 -0700
Message-ID: <1412626971-30271-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog121.obsmtp.com ([74.125.149.145]:50645 "HELO
	na3sys009aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751011AbaJFU2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 16:28:55 -0400
Received: by mail-pd0-f172.google.com with SMTP id ft15so3817561pdb.17
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 13:28:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a sparse warning introduced by Commit
0b5e8b8eeae40bae6ad7c7e91c97c3c0d0e57882 (net: Add Geneve tunneling
protocol driver) caught by kbuild test robot:

  # apt-get install sparse
  #   git checkout 0b5e8b8eeae40bae6ad7c7e91c97c3c0d0e57882
  #     make ARCH=x86_64 allmodconfig
  #       make C=1 CF=-D__CHECK_ENDIAN__
  #
  #
  #       sparse warnings: (new ones prefixed by >>)
  #
  #       >> net/ipv4/geneve.c:230:42: sparse: incorrect type in assignment (different base types)
  #          net/ipv4/geneve.c:230:42:    expected restricted __be32 [addressable] [assigned] [usertype] s_addr
  #             net/ipv4/geneve.c:230:42:    got unsigned long [unsigned] <noident>
  #

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 net/ipv4/geneve.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve.c
index f008c55..065cd94 100644
--- a/net/ipv4/geneve.c
+++ b/net/ipv4/geneve.c
@@ -227,7 +227,7 @@ static struct socket *geneve_create_sock(struct net *net, bool ipv6,
 		udp_conf.family = AF_INET6;
 	} else {
 		udp_conf.family = AF_INET;
-		udp_conf.local_ip.s_addr = INADDR_ANY;
+		udp_conf.local_ip.s_addr = htonl(INADDR_ANY);
 	}
 
 	udp_conf.local_udp_port = port;
-- 
1.7.9.5
