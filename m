From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [net-next PATCHv2 7/8] tun: update file current position
Date: Fri,  6 Dec 2013 10:24:08 +0800
Message-ID: <1386296649-6453-8-git-send-email-zwu.kernel@gmail.com>
References: <1386296649-6453-1-git-send-email-zwu.kernel@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386296649-6453-1-git-send-email-zwu.kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 drivers/net/tun.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 782e38b..e26cbea 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1356,6 +1356,8 @@ static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iovec *iv,
 	ret = tun_do_read(tun, tfile, iocb, iv, len,
 			  file->f_flags & O_NONBLOCK);
 	ret = min_t(ssize_t, ret, len);
+	if (ret > 0)
+		iocb->ki_pos = ret;
 out:
 	tun_put(tun);
 	return ret;
-- 
1.7.6.5
