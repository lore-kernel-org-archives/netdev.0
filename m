From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 4/6 v2] IB: address translation to map
	IP toIB addresses (GIDs)
Date: Fri, 10 Mar 2006 17:14:13 -0800
Message-ID: <ada1wx9hjfe.fsf@cisco.com>
References: <ORSMSX401FRaqbC8wSA0000000d@orsmsx401.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "Sean Hefty" <sean.hefty@intel.com>
In-Reply-To: <ORSMSX401FRaqbC8wSA0000000d@orsmsx401.amr.corp.intel.com> (Sean
	Hefty's message of "Mon, 6 Mar 2006 15:31:58 -0800")
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

The ib_addr module depends on CONFIG_INET, because it uses symbols
like arp_tbl, which are only exported if INET is enabled.

I fixed this up by creating a new (non-user-visible) config symbol to
control when ib_addr is built -- I put the following diff on top of
your patch in my tree:

diff --git a/drivers/infiniband/Kconfig b/drivers/infiniband/Kconfig
index bdf0891..48c8bb5 100644
--- a/drivers/infiniband/Kconfig
+++ b/drivers/infiniband/Kconfig
@@ -29,6 +29,11 @@ config INFINIBAND_USER_ACCESS
 	  libibverbs, libibcm and a hardware driver library from
 	  <http://www.openib.org>.
 
+config INFINIBAND_ADDR_TRANS
+	tristate
+	depends on INFINIBAND && INET
+	default y
+
 source "drivers/infiniband/hw/mthca/Kconfig"
 
 source "drivers/infiniband/ulp/ipoib/Kconfig"
diff --git a/drivers/infiniband/core/Makefile b/drivers/infiniband/core/Makefile
index 2393e9d..935851d 100644
--- a/drivers/infiniband/core/Makefile
+++ b/drivers/infiniband/core/Makefile
@@ -1,7 +1,8 @@
 obj-$(CONFIG_INFINIBAND) +=		ib_core.o ib_mad.o ib_sa.o \
-					ib_cm.o ib_addr.o
+					ib_cm.o 
 obj-$(CONFIG_INFINIBAND_USER_MAD) +=	ib_umad.o
 obj-$(CONFIG_INFINIBAND_USER_ACCESS) +=	ib_uverbs.o ib_ucm.o
+obj-$(CONFIG_INFINIBAND_ADDR_TRANS) +=	ib_addr.o
 
 ib_core-y :=			packer.o ud_header.o verbs.o sysfs.o \
 				device.o fmr_pool.o cache.o
