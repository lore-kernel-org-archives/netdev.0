From: Matthew Wilcox <willy@debian.org>
Subject: Re: [PATCH] pci_get_slot()
Date: Thu, 18 Dec 2003 20:00:31 +0000
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20031218200031.GK15674@parcelfarce.linux.theplanet.co.uk>
References: <20031015183213.GG16535@parcelfarce.linux.theplanet.co.uk> <20031218002444.GI6258@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Wilcox <willy@debian.org>,
	"David S. Miller" <davem@redhat.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	linux-pci@atrey.karlin.mff.cuni.cz, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Content-Disposition: inline
In-Reply-To: <20031218002444.GI6258@kroah.com>
List-Id: netdev.vger.kernel.org

On Wed, Dec 17, 2003 at 04:24:44PM -0800, Greg KH wrote:
> I've applied the pci portions of this patch to my trees and will send it
> on after 2.6.0 is out.

James Bottomley found a bug in it; could you also apply:

--- a/drivers/pci/search.c	17 Oct 2003 12:24:07 -0000	1.2
+++ b/drivers/pci/search.c	13 Dec 2003 22:36:04 -0000	1.3
@@ -125,7 +125,7 @@ struct pci_dev * pci_get_slot(struct pci
 	WARN_ON(in_interrupt());
 	spin_lock(&pci_bus_lock);
 
-	list_for_each(tmp, &bus->children) {
+	list_for_each(tmp, &bus->devices) {
 		dev = pci_dev_b(tmp);
 		if (dev->devfn == devfn)
 			goto out;

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
