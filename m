From: Gabriel C <nix.or.die@googlemail.com>
Subject: Re: [BUILD FAILURE]2.6.24-git6 build failure on sis190 ethernet driver
Date: Wed, 30 Jan 2008 05:43:03 +0100
Message-ID: <47A00057.9090306@googlemail.com>
References: <479FF1F0.10907@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	romieu@fr.zoreil.com, Andy Whitcroft <apw@shadowen.org>
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:35995 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751741AbYA3EnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 23:43:08 -0500
Received: by fg-out-1718.google.com with SMTP id e21so92120fga.17
        for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 20:43:07 -0800 (PST)
In-Reply-To: <479FF1F0.10907@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kamalesh Babulal wrote:
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
> 

Heh :) vger.kernel.org does not like emails directly from gmail , it seems =)

( sorry for sending this 3 time now )

The following patch should fix the build failure.

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index b570402..e48e4ad 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -326,7 +326,7 @@ static const struct {
 	{ "SiS 191 PCI Gigabit Ethernet adapter" },
 };
 
-static struct pci_device_id sis190_pci_tbl[] __devinitdata = {
+static const struct pci_device_id sis190_pci_tbl[] __devinitdata = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_SI, 0x0190), 0, 0, 0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_SI, 0x0191), 0, 0, 1 },
 	{ 0, },


Gabriel
