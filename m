From: "Bryan O'Sullivan" <bos@pathscale.com>
Subject: [PATCH 16 of 39] IB/ipath - enable freeze mode
 when shutting down device
Date: Thu, 29 Jun 2006 14:41:07 -0700
Message-ID: <fd5e733f02aceffe3434.1151617267@eng-12.pathscale.com>
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

Signed-off-by: Dave Olson <dave.olson@qlogic.com>
Signed-off-by: Bryan O'Sullivan <bryan.osullivan@qlogic.com>

diff -r 125471ee6c68 -r fd5e733f02ac drivers/infiniband/hw/ipath/ipath_driver.c
--- a/drivers/infiniband/hw/ipath/ipath_driver.c	Thu Jun 29 14:33:25 2006 -0700
+++ b/drivers/infiniband/hw/ipath/ipath_driver.c	Thu Jun 29 14:33:25 2006 -0700
@@ -1656,7 +1656,7 @@ void ipath_shutdown_device(struct ipath_
 	/* disable IBC */
 	dd->ipath_control &= ~INFINIPATH_C_LINKENABLE;
 	ipath_write_kreg(dd, dd->ipath_kregs->kr_control,
-			 dd->ipath_control);
+			 dd->ipath_control | INFINIPATH_C_FREEZEMODE);
 
 	/*
 	 * clear SerdesEnable and turn the leds off; do this here because
