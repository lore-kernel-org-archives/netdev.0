From: Dave Jones <davej@redhat.com>
Subject: Re: e100 problems in .23rc8 ?
Date: Sun, 21 Oct 2007 21:04:40 -0400
Message-ID: <20071022010440.GA11165@redhat.com>
References: <7DCDA0F058071B49AED9D3D7886C41BE0966AEDB@muon.jnpr.net> <47179F1F.3030202@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Mack <dmack@juniper.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, esandeen@redhat.com
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56126 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751104AbXJVBEw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Oct 2007 21:04:52 -0400
Content-Disposition: inline
In-Reply-To: <47179F1F.3030202@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 18, 2007 at 10:59:59AM -0700, Kok, Auke wrote:
 > David Mack wrote:
 > > It appears that the needed e100 fix made it into the Fedora
 > > 2.6.23.1-23.fc8 kernel. Boots reliably now.
 > > 
 > > Huge thanks and great work, guys.
 > 
 > DaveJ, I didn't push anything upstream. Can you verify this now works?

There was no e100 changes in the kernel above, so David just
got lucky. (The race doesn't always occur, so it sometimes appears
something got fixed.).

I included the patch below in the latest build, but I've not had
chance to try it on an e100 box yet..

	Dave

--- linux-2.6.23.noarch/drivers/net/e100.c~	2007-10-18 16:10:40.000000000 -0400
+++ linux-2.6.23.noarch/drivers/net/e100.c	2007-10-18 16:16:02.000000000 -0400
@@ -2682,6 +2682,8 @@ static int __devinit e100_probe(struct p
 	if (err)
 		DPRINTK(PROBE, ERR, "Error clearing wake event\n");
 
+	netif_poll_disable(netdev);
+
 	strcpy(netdev->name, "eth%d");
 	if((err = register_netdev(netdev))) {
 		DPRINTK(PROBE, ERR, "Cannot register net device, aborting.\n");

-- 
http://www.codemonkey.org.uk
