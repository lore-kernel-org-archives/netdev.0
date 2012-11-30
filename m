From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 02/17] pppoatm: allow assign only on a connected socket
Date: Fri, 30 Nov 2012 00:35:21 +0000
Message-ID: <1354235736-26833-3-git-send-email-dwmw2@infradead.org>
References: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Cc: chas@cmf.nrl.navy.mil, krzysiek@podlesie.net,
	David Woodhouse <David.Woodhouse@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:47038
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754887Ab2K3Agl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 19:36:41 -0500
In-Reply-To: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Mazur <krzysiek@podlesie.net>

The pppoatm does not check if used vcc is in connected state,
causing an Oops in pppoatm_send() when vcc->send() is called
on not fully connected socket.

Now pppoatm can be assigned only on connected sockets; otherwise
-EINVAL error is returned.

Signed-off-by: Krzysztof Mazur <krzysiek@podlesie.net>
Cc: Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 net/atm/pppoatm.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index 226dca9..f27a07a 100644
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -406,6 +406,8 @@ static int pppoatm_ioctl(struct socket *sock, unsigned int cmd,
 			return -ENOIOCTLCMD;
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
+		if (sock->state != SS_CONNECTED)
+			return -EINVAL;
 		return pppoatm_assign_vcc(atmvcc, argp);
 		}
 	case PPPIOCGCHAN:
-- 
1.8.0
