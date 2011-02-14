From: Vasiliy Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
Subject: [PATCH] bluethooth: sco: fix information leak to userspace
Date: Mon, 14 Feb 2011 13:54:26 +0300
Message-ID: <1297680867-11551-1-git-send-email-segoon@openwall.com>
Cc: security-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	"Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

struct sco_conninfo has one padding byte in the end.  Local variable
cinfo of type sco_conninfo is copied to userspace with this uninizialized
one byte, leading to old stack contents leak.

Signed-off-by: Vasiliy Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
---
 Compile tested.

 net/bluetooth/sco.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index 960c6d1..926ed39 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -703,6 +703,7 @@ static int sco_sock_getsockopt_old(struct socket *sock, int optname, char __user
 			break;
 		}
 
+		memset(&cinfo, 0, sizeof(cinfo));
 		cinfo.hci_handle = sco_pi(sk)->conn->hcon->handle;
 		memcpy(cinfo.dev_class, sco_pi(sk)->conn->hcon->dev_class, 3);
 
-- 
1.7.0.4
