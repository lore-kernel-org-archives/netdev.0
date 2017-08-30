From: Greg KH <gregkh@linuxfoundation.org>
Subject: [PATCH v3 net-next] staging: irda: fix init level for irda core
Date: Wed, 30 Aug 2017 13:16:49 +0200
Message-ID: <20170830111649.GA13000@kroah.com>
References: <20170829070929.GA15824@kroah.com>
 <20170829091417.GA9481@kroah.com>
 <20170829.093507.2166038228205751885.davem@davemloft.net>
 <20170829172608.GA4700@kroah.com>
 <20170829173129.GA11029@kroah.com>
 <20170829174622.GA25926@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
        samuel@sortiz.org, linux-kernel@vger.kernel.org,
        kernel test robot <fengguang.wu@intel.com>,
        Geert Uytterhoeven <geert@linux-m68k.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170829174622.GA25926@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When moving the IRDA code out of net/ into drivers/staging/irda/net, the
link order changes when IRDA is built into the kernel.  That causes a
kernel crash at boot time as netfilter isn't initialized yet.

To fix this, move the init call level of the irda core to be
device_initcall() as the link order keeps this being initialized at the
correct time.

Reported-by: kernel test robot <fengguang.wu@intel.com>
Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---

v3 - just change the initcall level, works so much simpler, thanks to
     DaveM for the idea.
v2 - don't force irda to be a module, make the Makefiles put irda back
     where it was before in the link order.

 drivers/staging/irda/net/irmod.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/irda/net/irmod.c b/drivers/staging/irda/net/irmod.c
index c5e35b85c477..4319f4ff66b0 100644
--- a/drivers/staging/irda/net/irmod.c
+++ b/drivers/staging/irda/net/irmod.c
@@ -190,7 +190,7 @@ static void __exit irda_cleanup(void)
  *
  * Jean II
  */
-subsys_initcall(irda_init);
+device_initcall(irda_init);
 module_exit(irda_cleanup);
 
 MODULE_AUTHOR("Dag Brattli <dagb@cs.uit.no> & Jean Tourrilhes <jt@hpl.hp.com>");
-- 
2.14.1
