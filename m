From: fgao@ikuai8.com
Subject: [PATCH net-next 1/1] driver: tun: Use new macro SOCK_IOC_MAGIC instead of literal number 0x89
Date: Tue, 25 Oct 2016 20:56:19 +0800
Message-ID: <1477400179-32200-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, jasowang@redhat.com, edumazet@google.com,
        pabeni@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg342.qq.com ([14.17.44.37]:49143 "EHLO smtpbg342.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932241AbcJYM5j (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Oct 2016 08:57:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

The current codes use _IOC_TYPE(cmd) == 0x89 to check if the cmd is one
socket ioctl command like SIOCGIFHWADDR. But the literal number 0x89 may
confuse readers. So create one macro SOCK_IOC_MAGIC like SPI_IOC_MAGIC to
enhance the readability.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 drivers/net/tun.c            | 2 +-
 include/uapi/linux/sockios.h | 2 ++
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 9328568..9efd185 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1985,7 +1985,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 	int le;
 	int ret;
 
-	if (cmd == TUNSETIFF || cmd == TUNSETQUEUE || _IOC_TYPE(cmd) == 0x89) {
+	if (cmd == TUNSETIFF || cmd == TUNSETQUEUE || _IOC_TYPE(cmd) == SOCK_IOC_MAGIC) {
 		if (copy_from_user(&ifr, argp, ifreq_len))
 			return -EFAULT;
 	} else {
diff --git a/include/uapi/linux/sockios.h b/include/uapi/linux/sockios.h
index 8e7890b..b8f42f2 100644
--- a/include/uapi/linux/sockios.h
+++ b/include/uapi/linux/sockios.h
@@ -24,6 +24,8 @@
 #define SIOCINQ		FIONREAD
 #define SIOCOUTQ	TIOCOUTQ        /* output queue size (not sent + not acked) */
 
+#define SOCK_IOC_MAGIC	0x89
+
 /* Routing table calls. */
 #define SIOCADDRT	0x890B		/* add routing table entry	*/
 #define SIOCDELRT	0x890C		/* delete routing table entry	*/
-- 
1.9.1
