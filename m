From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 8/16] cosa: fix error return code
Date: Sun,  5 Apr 2015 14:06:28 +0200
Message-ID: <1428235596-4757-9-git-send-email-Julia.Lawall@lip6.fr>
References: <1428235596-4757-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Jan \"Yenya\" Kasprzak" <kas@fi.muni.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1428235596-4757-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Return a negative error code on failure.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
identifier ret; expression e1,e2;
@@
(
if (\(ret < 0\|ret != 0\))
 { ... return ret; }
|
ret = 0
)
... when != ret = e1
    when != &ret
*if(...)
{
  ... when != ret = e2
      when forall
 return ret;
}
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/wan/cosa.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
index 88d121d..bcfa01a 100644
--- a/drivers/net/wan/cosa.c
+++ b/drivers/net/wan/cosa.c
@@ -579,6 +579,7 @@ static int cosa_probe(int base, int irq, int dma)
 		/* Register the network interface */
 		if (!(chan->netdev = alloc_hdlcdev(chan))) {
 			pr_warn("%s: alloc_hdlcdev failed\n", chan->name);
+			err = -ENOMEM;
 			goto err_hdlcdev;
 		}
 		dev_to_hdlc(chan->netdev)->attach = cosa_net_attach;
