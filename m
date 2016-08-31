From: Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
Subject: [PATCH 4/5] r8152: constify ethtool_ops structures
Date: Thu,  1 Sep 2016 00:21:22 +0200
Message-ID: <1472682083-5219-5-git-send-email-Julia.Lawall@lip6.fr>
References: <1472682083-5219-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1472682083-5219-1-git-send-email-Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Check for ethtool_ops structures that are only stored in the ethtool_ops
field of a net_device structure or passed as the second argument to
netdev_set_default_ethtool_ops.  These contexts are declared const, so
ethtool_ops structures that have these properties can be declared as const
also.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r disable optional_qualifier@
identifier i;
position p;
@@
static struct ethtool_ops i@p = { ... };

@ok1@
identifier r.i;
struct net_device e;
position p;
@@
e.ethtool_ops = &i@p;

@ok2@
identifier r.i;
expression e;
position p;
@@
netdev_set_default_ethtool_ops(e, &i@p)

@bad@
position p != {r.p,ok1.p,ok2.p};
identifier r.i;
@@
i@p

@depends on !bad disable optional_qualifier@
identifier r.i;
@@
static
+const
 struct ethtool_ops i = { ... };
// </smpl>

Suggested-by: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>

Signed-off-by: Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>

---
 drivers/net/usb/r8152.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index f41a8ad..f72f807 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -4032,7 +4032,7 @@ static int rtl8152_set_coalesce(struct net_device *netdev,
 	return ret;
 }
 
-static struct ethtool_ops ops = {
+static const struct ethtool_ops ops = {
 	.get_drvinfo = rtl8152_get_drvinfo,
 	.get_settings = rtl8152_get_settings,
 	.set_settings = rtl8152_set_settings,

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
