From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] Bogus return status in drivers/net/amd8111e.c
Date: Sat, 20 Dec 2003 01:17:18 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031220011718.A2442@electric-eye.fr.zoreil.com>
References: <20031219233231.A2420@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20031219233231.A2420@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Fri, Dec 19, 2003 at 11:32:31PM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patch applies on top of 2.6.0 + Jeff Garzik's 2.6.0-test11-bk5-netdrvr-exp2

The status variable is not set before branching to the error path.


 drivers/net/amd8111e.c |    2 ++
 1 files changed, 2 insertions(+)

diff -puN drivers/net/amd8111e.c~trivial-amd8111e-fscked-return-status drivers/net/amd8111e.c
--- linux-2.6.0-vanilla/drivers/net/amd8111e.c~trivial-amd8111e-fscked-return-status	2003-12-19 23:34:46.000000000 +0100
+++ linux-2.6.0-vanilla-fr/drivers/net/amd8111e.c	2003-12-19 23:37:15.000000000 +0100
@@ -1819,6 +1819,8 @@ static int __devinit amd8111e_probe_one(
 
 	pci_set_master(pdev);
 
+	err = -EIO;
+
 	/* Find power-management capability. */
 	if((pm_cap = pci_find_capability(pdev, PCI_CAP_ID_PM))==0){
 		printk(KERN_ERR "amd8111e: No Power Management capability, "

_
