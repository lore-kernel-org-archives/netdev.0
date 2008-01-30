From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [BUILD FAILURE]2.6.24-git6 build failure on sis190 ethernet driver
Date: Wed, 30 Jan 2008 06:34:51 +0100
Message-ID: <20080130053451.GA18641@uranus.ravnborg.org>
References: <479FF1F0.10907@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	romieu@fr.zoreil.com, Andy Whitcroft <apw@shadowen.org>
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpb.tele.dk ([80.160.77.98]:34642 "EHLO pasmtpB.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753155AbYA3Feu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 00:34:50 -0500
Content-Disposition: inline
In-Reply-To: <479FF1F0.10907@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 30, 2008 at 09:11:36AM +0530, Kamalesh Babulal wrote:
> Hi,
> 
> The 2.6.24-git6 kernel build fails on various x86_64 machines with the build failure
> 
> drivers/net/sis190.c:329: error: sis190_pci_tbl causes a section type conflict
> make[2]: *** [drivers/net/sis190.o] Error 1
> 
> # gcc --version (machine1)
> gcc (GCC) 4.1.1 20070105 (Red Hat 4.1.1-52)
> 
> # gcc --version (machine2)
> gcc (GCC) 4.1.1 20060525 (Red Hat 4.1.1-1)

Hi Kamalesh

I know another patch is circulating, but please try the following.
diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index b570402..0a5e024 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -1556,7 +1556,7 @@ static int __devinit sis190_get_mac_addr_from_eeprom(struct pci_dev *pdev,
 static int __devinit sis190_get_mac_addr_from_apc(struct pci_dev *pdev,
 						   struct net_device *dev)
 {
-	static const u16 __devinitdata ids[] = { 0x0965, 0x0966, 0x0968 };
+	static const u16 __devinitconst ids[] = { 0x0965, 0x0966, 0x0968 };
 	struct sis190_private *tp = netdev_priv(dev);
 	struct pci_dev *isa_bridge;
 	u8 reg, tmp8;

It is the better fix if you can confirm it working.
The section conflict issued by gcc happens because we try to
mix const and non-const data in the same section.

	Sam
