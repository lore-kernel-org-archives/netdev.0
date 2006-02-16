From: Shaun Pereira <spereira@tusc.com.au>
Subject: [PATCH 4/6] x25: Allow 32 bit socket ioctl in 64 bit kernel
Date: Thu, 16 Feb 2006 16:44:13 +1100
Message-ID: <1140068654.4941.22.camel@spereira05.tusc.com.au>
Reply-To: spereira@tusc.com.au
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932491AbWBPFqG@vger.kernel.org>
To: linux-kenel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

32 bit modular socket ioctl emulation for 64 bit kernel

This patch allows an x25 server application to run on a 64 bit kernel, by
fixing the following error message from the kernel. 

T2 kernel: schedule_timeout:
 wrong timeout value ffffffffffffffff from ffffffff88164796
  
Signed-off-by:Shaun Pereira <spereira@tusc.com.au>
Acked-by: Arnd Bergmann <arnd@arndb.de>

diff -uprN -X dontdiff linux-2.6.16-rc3-vanilla/net/x25/af_x25.c linux-2.6.16-rc3/net/x25/af_x25.c
--- linux-2.6.16-rc3-vanilla/net/x25/af_x25.c	2006-02-16 15:28:58.000000000 +1100
+++ linux-2.6.16-rc3/net/x25/af_x25.c	2006-02-16 15:29:04.000000000 +1100
@@ -743,7 +743,7 @@ out:
 	return rc;
 }
 
-static int x25_wait_for_data(struct sock *sk, int timeout)
+static int x25_wait_for_data(struct sock *sk, long timeout)
 {
 	DECLARE_WAITQUEUE(wait, current);
 	int rc = 0;
