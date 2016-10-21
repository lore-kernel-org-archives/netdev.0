From: fgao@ikuai8.com
Subject: [PATCH net-next 1/1] driver: tun: Forbid to set IFF_TUN and IFF_TAP at the same time
Date: Fri, 21 Oct 2016 14:14:12 +0800
Message-ID: <1477030452-1765-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, jasowang@redhat.com, edumazet@google.com,
        pabeni@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from SMTPBG352.QQ.COM ([183.57.50.167]:41079 "EHLO smtpbg352.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750856AbcJUGPt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Oct 2016 02:15:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

Current tun driver permits the ifr_flags is set with IFF_TUN and
IFF_TAP at the same time. But actually there is only IFF_TUN flag
works. And it does not make sense these two flags are set, so add
this check.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 drivers/net/tun.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 8093e39..c1f89c1 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1752,6 +1752,10 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		if (err < 0)
 			return err;
 
+		if ((ifr->ifr_flags & (IFF_TUN | IFF_TAP)) == (IFF_TUN | IFF_TAP)) {
+			return -EINVAL;
+		}
+
 		/* Set dev type */
 		if (ifr->ifr_flags & IFF_TUN) {
 			/* TUN device */
-- 
1.9.1
