From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch - Nicholas's tree] netconsole: Missing unlock on error path
Date: Sat, 3 Oct 2015 22:05:24 +0300
Message-ID: <20151003190524.GA766@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Nicholas Bellinger <nab@linux-iscsi.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Tejun Heo <tj@kernel.org>, Christoph Hellwig <hch@lst.de>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We added new locking to this function but we missed one error path which
needs an unlock.

Fixes: cdacad4993f4 ('netconsole: use per-attribute show and store methods')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
This is going through Nicholas Bellinger's tree not net-next.

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 8783169..06ee639 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -535,7 +535,7 @@ static ssize_t remote_ip_store(struct config_item *item, const char *buf,
 		if (in6_pton(buf, count, nt->np.remote_ip.in6.s6_addr, -1, &end) > 0) {
 			if (*end && *end != '\n') {
 				pr_err("invalid IPv6 address at: <%c>\n", *end);
-				return -EINVAL;
+				goto out_unlock;
 			}
 			nt->np.ipv6 = true;
 		} else
