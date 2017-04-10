From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net: make struct net_device::min_header_len 8-bit
Date: Mon, 10 Apr 2017 11:25:26 +0300
Message-ID: <20170410082526.GC24514@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:33067 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751864AbdDJIZa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 04:25:30 -0400
Received: by mail-lf0-f68.google.com with SMTP id r36so10723997lfi.0
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 01:25:29 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This field is never big enough to warrant 16-bitness.

8-bit accesses enjoy shorted encoding on i386/x86_64 than 16-bit
accesses:

	add/remove: 0/0 grow/shrink: 0/2 up/down: 0/-10 (-10)
	function                                     old     new   delta
	loopback_setup                               169     164      -5
	ether_setup                                  148     143      -5

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/linux/netdevice.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1715,7 +1715,7 @@ struct net_device {
 	unsigned int		max_mtu;
 	unsigned short		type;
 	unsigned short		hard_header_len;
-	unsigned short		min_header_len;
+	unsigned char		min_header_len;
 
 	unsigned short		needed_headroom;
 	unsigned short		needed_tailroom;
