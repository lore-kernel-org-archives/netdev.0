From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] sfc: cleanup a condition in efx_udp_tunnel_del()
Date: Wed, 22 Mar 2017 12:10:02 +0300
Message-ID: <20170322091002.GB14520@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Edward Cree <ecree@solarflare.com>,
        Bert Kenward <bkenward@solarflare.com>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Solarflare linux maintainers <linux-net-drivers@solarflare.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Presumably if there is an "add" function, there is also a "del"
function.  But it causes a static checker warning because it looks like
a common cut and paste bug.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 8c4c273643dc..203c8c3752e7 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2404,7 +2404,7 @@ static void efx_udp_tunnel_del(struct net_device *dev, struct udp_tunnel_info *t
 	tnl.type = (u16)efx_tunnel_type;
 	tnl.port = ti->port;
 
-	if (efx->type->udp_tnl_add_port)
+	if (efx->type->udp_tnl_del_port)
 		(void)efx->type->udp_tnl_del_port(efx, tnl);
 }
 
