From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH] [SIS190] Constify data marked as __devinitdata
Date: Wed, 30 Jan 2008 12:25:59 +0100
Message-ID: <20080130112559.GA21346@uranus.ravnborg.org>
References: <1201690388-9052-1-git-send-email-jonas@southpole.se> <Pine.LNX.4.64.0801301220570.15249@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jonas Bonn <jonas@southpole.se>, netdev@vger.kernel.org,
	romieu@fr.zoreil.com, linux-kernel@vger.kernel.org
To: Jan Engelhardt <jengelh@computergmbh.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:52436 "EHLO pasmtpA.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753335AbYA3LZ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 06:25:56 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801301220570.15249@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 30, 2008 at 12:23:23PM +0100, Jan Engelhardt wrote:
> 
> On Jan 30 2008 11:53, Jonas Bonn wrote:
> >
> >This fixes build error as gcc complains about a "section type conflict"
> >due to the const __devinitdata in sis190_get_mac_addr_from_apc().
> 
> >-static struct pci_device_id sis190_pci_tbl[] __devinitdata = {
> >+static const struct pci_device_id sis190_pci_tbl[] __devinitdata = {
> > 	{ PCI_DEVICE(PCI_VENDOR_ID_SI, 0x0190), 0, 0, 0 },
> > 	{ PCI_DEVICE(PCI_VENDOR_ID_SI, 0x0191), 0, 0, 1 },
> > 	{ 0, },
> 
> Eh? Did you mean to
> 
> -        static const u16 __devinitdata ids[] = { 0x0965, 0x0966, 0x0968 };
> +        static u16 __devinitdata ids[] = { 0x0965, 0x0966, 0x0968 };
> 
> instead? Because AFAIK, const *and* __sectionmarker does not mix.

We have just introduced __initconst, __cpuinitconst, __meminitconst
for const data.
So the patch is wrong.

	Sam
