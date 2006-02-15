From: Shaun Pereira <spereira@tusc.com.au>
Subject: [PATCH 4/6] x25: Allow 32 bit socket ioctl in 64 bit kernel
Date: Thu, 16 Feb 2006 09:19:53 +1100
Message-ID: <1140041993.8745.28.camel@spereira05.tusc.com.au>
Reply-To: spereira@tusc.com.au
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andre Hendry <ahendry@tusc.com.au>, Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751334AbWBOWXK@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kenel <linux-kernel@vger.kernel.org>,
	x25 maintainer <eis@baty.hanse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch allows an x25 server application to run on a 64 bit kernel,
by fixing the following error message from the kernel. 

T2 kernel: schedule_timeout:
 wrong timeout value ffffffffffffffff from ffffffff88164796
  
Signed-off-by:Shaun Pereira <spereira@tusc.com.au>
Acked-by: Arnd Bergmann <arnd@arndb.de>

diff -uprN -X dontdiff linux-2.6.16-rc3-vanilla/net/x25/af_x25.c
linux-2.6.16-rc3/net/x25/af_x25.c
--- linux-2.6.16-rc3-vanilla/net/x25/af_x25.c	2006-02-15
11:13:50.000000000 +1100
+++ linux-2.6.16-rc3/net/x25/af_x25.c	2006-02-15 11:14:06.000000000
+1100
@@ -743,7 +743,7 @@ out:
 	return rc;
 }
 
-static int x25_wait_for_data(struct sock *sk, int timeout)
+static int x25_wait_for_data(struct sock *sk, long timeout)
 {
 	DECLARE_WAITQUEUE(wait, current);
 	int rc = 0;
