From: Wenliang Fan <fanwlexca@gmail.com>
Subject: [PATCH] drivers/net/hamradio: Integer overflow in hdlcdrv_ioctl()
Date: Tue, 17 Dec 2013 11:25:28 +0800
Message-ID: <1387250728-10795-1-git-send-email-fanwlexca@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Wenliang Fan <fanwlexca@gmail.com>
To: davem@davemloft.net, michael.opdenacker@free-electrons.com,
	gaofeng@cn.fujitsu.com, akpm@linux-foundation.org,
	t.sailer@alumni.ethz.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The local variable 'bi' comes from userspace. If userspace passed a
large number to 'bi.data.calibrate', there would be an integer overflow
in the following line:
	s->hdlctx.calibrate = bi.data.calibrate * s->par.bitrate / 16;

Signed-off-by: Wenliang Fan <fanwlexca@gmail.com>
---
 drivers/net/hamradio/hdlcdrv.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
index 3169252..5d78c1d 100644
--- a/drivers/net/hamradio/hdlcdrv.c
+++ b/drivers/net/hamradio/hdlcdrv.c
@@ -571,6 +571,8 @@ static int hdlcdrv_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	case HDLCDRVCTL_CALIBRATE:
 		if(!capable(CAP_SYS_RAWIO))
 			return -EPERM;
+		if (bi.data.calibrate > INT_MAX / s->par.bitrate)
+			return -EINVAL;
 		s->hdlctx.calibrate = bi.data.calibrate * s->par.bitrate / 16;
 		return 0;
 
-- 
1.8.5.rc1.28.g7061504
