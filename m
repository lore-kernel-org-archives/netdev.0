From: "Bryan O'Sullivan" <bos@pathscale.com>
Subject: [PATCH 23 of 39] IB/ipath - disallow send of
 invalid packet sizes over UD
Date: Thu, 29 Jun 2006 14:41:14 -0700
Message-ID: <8e39364c2402304872e6.1151617274@eng-12.pathscale.com>
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

diff -r 811021b6c112 -r 8e39364c2402 drivers/infiniband/hw/ipath/ipath_ud.c
--- a/drivers/infiniband/hw/ipath/ipath_ud.c	Thu Jun 29 14:33:26 2006 -0700
+++ b/drivers/infiniband/hw/ipath/ipath_ud.c	Thu Jun 29 14:33:26 2006 -0700
@@ -274,6 +274,11 @@ int ipath_post_ud_send(struct ipath_qp *
 		}
 		len += wr->sg_list[i].length;
 		ss.num_sge++;
+	}
+	/* Check for invalid packet size. */
+	if (len > ipath_layer_get_ibmtu(dev->dd)) {
+		ret = -EINVAL;
+		goto bail;
 	}
 	extra_bytes = (4 - len) & 3;
 	nwords = (len + extra_bytes) >> 2;
