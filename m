From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] ax25: cleanup a range test
Date: Fri, 18 Oct 2013 12:06:56 +0300
Message-ID: <20131018090656.GA23528@longonot.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Joerg Reuter <jreuter@yaina.de>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current test works fine in practice.  The "amount" variable is
actually used as a boolean so negative values or any non-zero values
count as "true".  However since we don't allow numbers greater than one,
let's not allow negative numbers either.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index 4b4d2b7..a00123e 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1735,7 +1735,7 @@ static int ax25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 			res = -EFAULT;
 			break;
 		}
-		if (amount > AX25_NOUID_BLOCK) {
+		if (amount < 0 || amount > AX25_NOUID_BLOCK) {
 			res = -EINVAL;
 			break;
 		}
