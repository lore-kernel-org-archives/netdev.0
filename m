From: Xi Wang <xi.wang@gmail.com>
Subject: [PATCH 2/2] ax25: integer overflows in ax25_ctl_ioctl()
Date: Tue, 22 Nov 2011 23:35:13 -0500
Message-ID: <BE9FC917-43B3-47E1-BFC7-5E5F2B1F68A1@gmail.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Joerg Reuter <jreuter@yaina.de>,
	Ralf Baechle <ralf@linux-mips.org>,
	David Miller <davem@davemloft.net>, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ax25_ctl_ioctl() misses several bound checks on the user-controlled value.

Signed-off-by: Xi Wang <xi.wang@gmail.com>
---
 net/ax25/af_ax25.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index be6a8cf..bd47e22 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -402,14 +402,14 @@ static int ax25_ctl_ioctl(const unsigned int cmd, void __user *arg)
 		break;
 
 	case AX25_T1:
-		if (ax25_ctl.arg < 1)
+		if (ax25_ctl.arg < 1 || ax25_ctl.arg > 30)
 			goto einval_put;
 		ax25->rtt = (ax25_ctl.arg * HZ) / 2;
 		ax25->t1  = ax25_ctl.arg * HZ;
 		break;
 
 	case AX25_T2:
-		if (ax25_ctl.arg < 1)
+		if (ax25_ctl.arg < 1 || ax25_ctl.arg > 20)
 			goto einval_put;
 		ax25->t2 = ax25_ctl.arg * HZ;
 		break;
@@ -422,10 +422,14 @@ static int ax25_ctl_ioctl(const unsigned int cmd, void __user *arg)
 		break;
 
 	case AX25_T3:
+		if (ax25_ctl.arg > 3600)
+			goto einval_put;
 		ax25->t3 = ax25_ctl.arg * HZ;
 		break;
 
 	case AX25_IDLE:
+		if (ax25_ctl.arg > 65535)
+			goto einval_put;
 		ax25->idle = ax25_ctl.arg * 60 * HZ;
 		break;
 
-- 
1.7.5.4

