From: Li Yewang <lyw@cn.fujitsu.com>
Subject: [PATCH] Can not send icmp netunreach packet
Date: Tue, 26 Feb 2008 14:34:01 +0800
Message-ID: <47C3B2D9.9090601@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, swhiteho@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49363 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753023AbYBZGfn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Feb 2008 01:35:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All

   There is a bug about icmp netunreach.
   If the kernel does not find a route for a packet, 
   it must send a icmp netunreach packet to the source host, 
   and  discard  the packet. But the  kernel  does not send 
   a icmp netunreach packet because of the  fib_lookup
   return value  of -ESRCH when a route  is not found. 

Signed-off-by: Li Yewang <lyw@cn.fujitsu.com>

diff -Nurp net/core_back/fib_rules.c net/core/fib_rules.c
--- net/core_back/fib_rules.c   2008-02-25 13:15:37.000000000 +0800
+++ net/core/fib_rules.c        2008-02-25 13:16:01.000000000 +0800
@@ -188,7 +188,7 @@ jumped:
 		}
 	}
 
-	err = -ESRCH;
+	err = -ENETUNREACH;
 out:
 	rcu_read_unlock();

