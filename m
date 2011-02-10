From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] Don't potentially dereference NULL in
 net/dcb/dcbnl.c:dcbnl_getapp()
Date: Thu, 10 Feb 2011 22:57:16 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1102102253230.8012@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
	Dan Carpenter <error27@gmail.com>,
	Shmulik Ravid <shmulikr@broadcom.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Lucy Liu <lucy.liu@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

nla_nest_start() may return NULL. If it does then we'll blow up in 
nla_nest_end() when we dereference the pointer.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 dcbnl.c |    3 +++
 1 file changed, 3 insertions(+)

  only compile tested.

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 6b03f56..13cdc30 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -626,6 +626,9 @@ static int dcbnl_getapp(struct net_device *netdev, struct nlattr **tb,
 	dcb->cmd = DCB_CMD_GAPP;
 
 	app_nest = nla_nest_start(dcbnl_skb, DCB_ATTR_APP);
+	if (!app_nest)
+		goto out_cancel;
+
 	ret = nla_put_u8(dcbnl_skb, DCB_APP_ATTR_IDTYPE, idtype);
 	if (ret)
 		goto out_cancel;
-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Plain text mails only, please.
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
