From: "Bryan O'Sullivan" <bos@pathscale.com>
Subject: [PATCH 24 of 39] IB/ipath - don't confuse the
 max message size with the MTU
Date: Thu, 29 Jun 2006 14:41:15 -0700
Message-ID: <e952aedb0e94b4f8ccc1.1151617275@eng-12.pathscale.com>
References: <patchbomb.1151617251@eng-12.pathscale.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
In-Reply-To: <patchbomb.1151617251@eng-12.pathscale.com>
To: akpm@osdl.org,
	rdreier@cisco.com,
	mst@mellanox.co.il
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ralph Campbell <ralph.campbell@qlogic.com>
Signed-off-by: Bryan O'Sullivan <bryan.osullivan@qlogic.com>

diff -r 8e39364c2402 -r e952aedb0e94 drivers/infiniband/hw/ipath/ipath_verbs.c
--- a/drivers/infiniband/hw/ipath/ipath_verbs.c	Thu Jun 29 14:33:26 2006 -0700
+++ b/drivers/infiniband/hw/ipath/ipath_verbs.c	Thu Jun 29 14:33:26 2006 -0700
@@ -695,7 +695,7 @@ static int ipath_query_port(struct ib_de
 		ipath_layer_get_lastibcstat(dev->dd) & 0xf];
 	props->port_cap_flags = dev->port_cap_flags;
 	props->gid_tbl_len = 1;
-	props->max_msg_sz = 4096;
+	props->max_msg_sz = 0x80000000;
 	props->pkey_tbl_len = ipath_layer_get_npkeys(dev->dd);
 	props->bad_pkey_cntr = ipath_layer_get_cr_errpkey(dev->dd) -
 		dev->z_pkey_violations;
