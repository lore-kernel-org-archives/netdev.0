From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] netrom: check that user string is terminated
Date: Wed, 23 Nov 2011 09:52:40 +0300
Message-ID: <20111123065240.GD6871@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We do an strcpy() of mnemonic in nr_add_node().

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/netrom/nr_route.c b/net/netrom/nr_route.c
index 915a87b..e126c48 100644
--- a/net/netrom/nr_route.c
+++ b/net/netrom/nr_route.c
@@ -670,6 +670,8 @@ int nr_rt_ioctl(unsigned int cmd, void __user *arg)
 	case SIOCADDRT:
 		if (copy_from_user(&nr_route, arg, sizeof(struct nr_route_struct)))
 			return -EFAULT;
+		if (strlen(nr_route.mnemonic) >= sizeof(nr_route.mnemonic))
+			return -EINVAL;
 		if ((dev = nr_ax25_dev_get(nr_route.device)) == NULL)
 			return -EINVAL;
 		if (nr_route.ndigis < 0 || nr_route.ndigis > AX25_MAX_DIGIS) {
