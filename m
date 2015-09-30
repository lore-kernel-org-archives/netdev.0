From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v2] atm: remove 'struct zatm_t_hist'
Date: Wed, 30 Sep 2015 17:32:01 +0200
Message-ID: <2417914.UvIGGyvL3v@wuerfel>
References: <1443612402-3000775-1-git-send-email-arnd@arndb.de> <1443612402-3000775-8-git-send-email-arnd@arndb.de> <1443626675.3494.41.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, y2038@lists.linaro.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-atm-general@lists.sourceforge.net
To: "Charles (Chas) Williams" <3chas3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443626675.3494.41.camel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The zatm_t_hist structure is not used anywhere in the kernel, but is
exported to user space. As we are trying to eliminate uses of time_t
in the kernel for y2038 compatibility, the current definition triggers
checking tools because it contains 'struct timeval'.

As pointed out by Chas Williams, the only user of this structure was
the ZATM_GETHIST ioctl command that has been removed a long time ago,
and we can remove the structure as well without breaking any user
space.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Chas Williams <3chas3@gmail.com>
Cc: linux-atm-general@lists.sourceforge.net

diff --git a/include/uapi/linux/atm_zatm.h b/include/uapi/linux/atm_zatm.h
index 10f0fa29454f..9c9c6ad55f14 100644
--- a/include/uapi/linux/atm_zatm.h
+++ b/include/uapi/linux/atm_zatm.h
@@ -35,12 +35,6 @@ struct zatm_pool_req {
 	struct zatm_pool_info info;	/* actual information */
 };
 
-struct zatm_t_hist {
-	struct timeval real;		/* real (wall-clock) time */
-	struct timeval expected;	/* expected real time */
-};
-
-
 #define ZATM_OAM_POOL		0	/* free buffer pool for OAM cells */
 #define ZATM_AAL0_POOL		1	/* free buffer pool for AAL0 cells */
 #define ZATM_AAL5_POOL_BASE	2	/* first AAL5 free buffer pool */
