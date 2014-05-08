From: Johan Hovold <jhovold-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH RESEND 4/5] net: cpsw: fix null dereference at probe
Date: Thu,  8 May 2014 10:09:23 +0200
Message-ID: <1399536564-7626-5-git-send-email-jhovold@gmail.com>
References: <1399534639-4947-1-git-send-email-jhovold@gmail.com>
 <1399536564-7626-1-git-send-email-jhovold@gmail.com>
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
	Johan Hovold <jhovold-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1399536564-7626-1-git-send-email-jhovold-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Fix null-pointer dereference at probe when the mdio platform device is
missing (e.g. when it has been disabled in DT).

Cc: stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>	# v3.8
Signed-off-by: Johan Hovold <jhovold-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ethernet/ti/cpsw.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 18d83d8d7f74..db9360cd861c 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1871,6 +1871,10 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 		mdio_node = of_find_node_by_phandle(be32_to_cpup(parp));
 		phyid = be32_to_cpup(parp+1);
 		mdio = of_find_device_by_node(mdio_node);
+		if (!mdio) {
+			pr_err("Missing mdio platform device\n");
+			return -EINVAL;
+		}
 		snprintf(slave_data->phy_id, sizeof(slave_data->phy_id),
 			 PHY_ID_FMT, mdio->name, phyid);
 
-- 
1.8.3.2

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
