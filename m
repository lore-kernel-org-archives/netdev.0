From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] drivers/atm/he.c: remove ancient version string
Date: Mon, 18 Dec 2006 05:50:03 +0100
Message-ID: <20061218045003.GD10316@stusta.de>
References: <20061217125622.GA4973@martell.zuzino.mipt.ru> <20061217.171159.32723537.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: adobriyan@gmail.com, netdev@vger.kernel.org,
	webmaster@programmierforen.de, kernel-janitors@lists.osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:4395 "HELO
	mailout.stusta.mhn.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752977AbWLREuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Dec 2006 23:50:05 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061217.171159.32723537.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 17, 2006 at 05:11:59PM -0800, David Miller wrote:
> From: Alexey Dobriyan <adobriyan@gmail.com>
> Date: Sun, 17 Dec 2006 15:56:22 +0300
> 
> > From: Andi Drebes <webmaster@programmierforen.de>
> > 
> >    text    data     bss     dec     hex filename
> >   20015     480      28   20523    502b drivers/atm/he.o
> >   19997     480      28   20505    5019 drivers/atm/he.o
> > 
> > Signed-off-by: Andi Drebes <webmaster@programmierforen.de>
> > Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> 
> As Adrian said, this CVS string is totally useless.
> 
> That being said, it should be replaced with an
> appropriate piece of versioning information, like
> the ones we use via MODULE_VERSION() in other drivers.

Which versioning information?

There does not seem to be any versioning information that is 
getting updated.

There are some truly exceptional cases where maintainers are using and 
updating version strings, but in all other cases there's simply nothing 
that's worth being printed.

> I'll be happy to apply a patch which gets rid of the
> CVS references, and replaces it with something useful.

Patch below.

> Thanks.

cu
Adrian


<--  snip  -->


This patch removes the ancient version string.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 drivers/atm/he.c |   10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

--- linux-2.6.20-rc1-mm1/drivers/atm/he.c.old	2006-12-18 05:35:19.000000000 +0100
+++ linux-2.6.20-rc1-mm1/drivers/atm/he.c	2006-12-18 05:39:40.000000000 +0100
@@ -1,5 +1,3 @@
-/* $Id: he.c,v 1.18 2003/05/06 22:57:15 chas Exp $ */
-
 /*
 
   he.c
@@ -99,10 +97,6 @@
 #define HPRINTK(fmt,args...)	do { } while (0)
 #endif /* HE_DEBUG */
 
-/* version definition */
-
-static char *version = "$Id: he.c,v 1.18 2003/05/06 22:57:15 chas Exp $";
-
 /* declarations */
 
 static int he_open(struct atm_vcc *vcc);
@@ -366,7 +360,7 @@ he_init_one(struct pci_dev *pci_dev, con
 	struct he_dev *he_dev = NULL;
 	int err = 0;
 
-	printk(KERN_INFO "he: %s\n", version);
+	printk(KERN_INFO "ATM he driver\n");
 
 	if (pci_enable_device(pci_dev))
 		return -EIO;
@@ -2933,7 +2927,7 @@ he_proc_read(struct atm_dev *dev, loff_t
 
 	left = *pos;
 	if (!left--)
-		return sprintf(page, "%s\n", version);
+		return sprintf(page, "ATM he driver\n");
 
 	if (!left--)
 		return sprintf(page, "%s%s\n\n",

