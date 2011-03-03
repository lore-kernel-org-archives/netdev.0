From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/3 v2] mii: Convert printks to netdev_info
Date: Thu, 03 Mar 2011 12:46:30 -0800
Message-ID: <1299185190.4338.163.camel@Joe-Laptop>
References: <1b384ead46d062ba189b64649710a5625b7f6a2b.1299086044.git.joe@perches.com>
	 <20110303.122148.245410126.davem@davemloft.net>
	 <1299184181.4338.152.camel@Joe-Laptop>
	 <20110303.123225.242141985.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4082 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758472Ab1CCUqb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 15:46:31 -0500
In-Reply-To: <20110303.123225.242141985.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a bit more data to the output.
Convert string speeds to integer.
Object size reduced a tiny bit.
$ size drivers/net/mii.o*
   text	   data	    bss	    dec	    hex	filename
   4155	     56	   1000	   5211	   145b	drivers/net/mii.o.new
   4184	     56	   1000	   5240	   1478	drivers/net/mii.o.old

Signed-off-by: Joe Perches <joe@perches.com>

---

On Thu, 2011-03-03 at 12:32 -0800, David Miller wrote:
> > This change is stuffed up somehow, it's
> > a reversion of the tun.c change.
> Oops.
> > Let me send you a new/correct patch right now.
> Ok.

Sorry about that.  Here's the appropriate patch.

It seems apparent I don't know how to use git properly.

I commited the change, then thought I should see
what the size difference was and add that to the
changelog.

I believe I did this:

<edits drivers/net/mii.c>
make drivers/net/mii.o
git commit -s drivers/net/mii.c
mv drivers/net/mii.o drivers/net/mii.o.new
git checkout master -- drivers/net/mii.c
make drivers/net/mii.o
mv drivers/net/mii.o drivers/net/mii.i.old
git checkout <branch> -- drivers/net/mii.c
size drivers/net/mii.o.*
 etc...
git commit --amend drivers/net/mii.c (add etc...)

tun revert?  No mii change?  huh?

 drivers/net/mii.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/mii.c b/drivers/net/mii.c
index 210b2b1..0a6c6a2 100644
--- a/drivers/net/mii.c
+++ b/drivers/net/mii.c
@@ -354,7 +354,7 @@ unsigned int mii_check_media (struct mii_if_info *mii,
 	if (!new_carrier) {
 		netif_carrier_off(mii->dev);
 		if (ok_to_print)
-			printk(KERN_INFO "%s: link down\n", mii->dev->name);
+			netdev_info(mii->dev, "link down\n");
 		return 0; /* duplex did not change */
 	}
 
@@ -381,12 +381,12 @@ unsigned int mii_check_media (struct mii_if_info *mii,
 		duplex = 1;
 
 	if (ok_to_print)
-		printk(KERN_INFO "%s: link up, %sMbps, %s-duplex, lpa 0x%04X\n",
-		       mii->dev->name,
-		       lpa2 & (LPA_1000FULL | LPA_1000HALF) ? "1000" :
-		       media & (ADVERTISE_100FULL | ADVERTISE_100HALF) ? "100" : "10",
-		       duplex ? "full" : "half",
-		       lpa);
+		netdev_info(mii->dev, "link up, %uMbps, %s-duplex, lpa 0x%04X\n",
+			    lpa2 & (LPA_1000FULL | LPA_1000HALF) ? 1000 :
+			    media & (ADVERTISE_100FULL | ADVERTISE_100HALF) ?
+			    100 : 10,
+			    duplex ? "full" : "half",
+			    lpa);
 
 	if ((init_media) || (mii->full_duplex != duplex)) {
 		mii->full_duplex = duplex;


