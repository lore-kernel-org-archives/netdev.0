From: Shaun Pereira <spereira@tusc.com.au>
Subject: [PATCH 4/4 -2.6.15]: 32 bit (socket layer) ioctl emulation for 64
	bit kernels
Date: Thu, 12 Jan 2006 17:03:43 +1100
Message-ID: <1137045823.5221.25.camel@spereira05.tusc.com.au>
Reply-To: spereira@tusc.com.au
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030307AbWALGDv@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Andi Kleen <ak@muc.de>,
	linux-kenel <linux-kernel@vger.kernel.org>,
	x25 maintainer <eis@baty.hanse.de>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A small fix for the following error, when trying to run a 64 bit x25
server application.

T2 kernel: schedule_timeout: 
 wrong timeout value ffffffffffffffff from ffffffff88164796

diff -uprN -X dontdiff linux-2.6.15-vanilla/net/x25/af_x25.c
linux-2.6.15/net/x25/af_x25.c
--- linux-2.6.15-vanilla/net/x25/af_x25.c	2006-01-12 16:15:46.000000000
+1100
+++ linux-2.6.15/net/x25/af_x25.c	2006-01-12 16:14:27.000000000 +1100
@@ -747,7 +747,7 @@ out:
 	return rc;
 }
 
-static int x25_wait_for_data(struct sock *sk, int timeout)
+static int x25_wait_for_data(struct sock *sk, long timeout)
 {
 	DECLARE_WAITQUEUE(wait, current);
 	int rc = 0;
