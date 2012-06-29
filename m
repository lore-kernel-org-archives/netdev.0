From: Vincent Sanders <vincent.sanders@collabora.co.uk>
Subject: [PATCH net-next 07/15] scm: allow AF_BUS sockets to send ancillary data
Date: Fri, 29 Jun 2012 17:45:46 +0100
Message-ID: <1340988354-26981-8-git-send-email-vincent.sanders@collabora.co.uk>
References: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk>
Cc: Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	Vincent Sanders <vincent.sanders@collabora.co.uk>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>

Similar to UNIX domain sockets AF_BUS sockets support passing file
descriptors and process credentials which requires supporting passing
control messages.

The core socket level control messages processing requires extending
to allow sockets other than PF_UNIX to send SCM_RIGHTS type messages.

Signed-off-by: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Signed-off-by: Vincent Sanders <vincent.sanders@collabora.co.uk>
---
 net/core/scm.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/scm.c b/net/core/scm.c
index 611c5ef..87e3152 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -158,7 +158,8 @@ int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *p)
 		switch (cmsg->cmsg_type)
 		{
 		case SCM_RIGHTS:
-			if (!sock->ops || sock->ops->family != PF_UNIX)
+			if (!sock->ops || (sock->ops->family != PF_UNIX &&
+					   sock->ops->family != PF_BUS))
 				goto error;
 			err=scm_fp_copy(cmsg, &p->fp);
 			if (err<0)
-- 
1.7.10
