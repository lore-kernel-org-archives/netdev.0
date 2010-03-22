From: Dan Carpenter <error27@gmail.com>
Subject: [patch] ewrk3: range checking problem
Date: Mon, 22 Mar 2010 15:07:28 +0300
Message-ID: <20100322120728.GD21571@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The range checking here is wrong.  It should be HASH_TABLE_LEN which 
is 512.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/ewrk3.c b/drivers/net/ewrk3.c
index 91e59f3..ae02de1 100644
--- a/drivers/net/ewrk3.c
+++ b/drivers/net/ewrk3.c
@@ -1776,8 +1776,7 @@ static int ewrk3_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 		break;
 	case EWRK3_SET_MCA:	/* Set a multicast address */
 		if (capable(CAP_NET_ADMIN)) {
-			if (ioc->len > 1024)
-			{
+			if (ioc->len > HASH_TABLE_LEN) {
 				status = -EINVAL;
 				break;
 			}
