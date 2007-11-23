From: Valentine Barshak <vbarshak@ru.mvista.com>
Subject: [PATCH 3/3] PowerPC: ibm_newemac call dev_set_drvdata() before
	tah_reset()
Date: Fri, 23 Nov 2007 22:14:10 +0300
Message-ID: <20071123191410.GA25742@ru.mvista.com>
References: <20071123190747.GA25654@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: linuxppc-dev@ozlabs.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20071123190747.GA25654@ru.mvista.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

The patch moves dev_set_drvdata(&ofdev->dev, dev) up before tah_reset(ofdev)
is called to avoid a NULL pointer dereference, since tah_reset uses drvdata.

Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
---
 drivers/net/ibm_newemac/tah.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

diff -pruN linux-2.6.orig/drivers/net/ibm_newemac/tah.c linux-2.6/drivers/net/ibm_newemac/tah.c
--- linux-2.6.orig/drivers/net/ibm_newemac/tah.c	2007-11-23 21:27:57.000000000 +0300
+++ linux-2.6/drivers/net/ibm_newemac/tah.c	2007-11-23 21:35:12.000000000 +0300
@@ -116,13 +116,14 @@ static int __devinit tah_probe(struct of
 		goto err_free;
 	}
 
+	dev_set_drvdata(&ofdev->dev, dev);
+
 	/* Initialize TAH and enable IPv4 checksum verification, no TSO yet */
 	tah_reset(ofdev);
 
 	printk(KERN_INFO
 	       "TAH %s initialized\n", ofdev->node->full_name);
 	wmb();
-	dev_set_drvdata(&ofdev->dev, dev);
 
 	return 0;
