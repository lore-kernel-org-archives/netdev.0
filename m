From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: sis190 build breakage
Date: Wed, 30 Jan 2008 04:28:38 +0100
Message-ID: <20080130032838.GA17881@uranus.ravnborg.org>
References: <20080129215023.GA24152@stro.at> <20080129220310.GC15445@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: maximilian attems <max@stro.at>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:42347 "EHLO pasmtpA.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759975AbYA3D2v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2008 22:28:51 -0500
Content-Disposition: inline
In-Reply-To: <20080129220310.GC15445@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 29, 2008 at 11:03:10PM +0100, Francois Romieu wrote:
> maximilian attems <max@stro.at> :
> >   CC [M]  drivers/net/sis190.o
> >   drivers/net/sis190.c:329: error: sis190_pci_tbl causes a section type conflict
> >   make[5]: *** [drivers/net/sis190.o] Error 1
> > 
> > gcc --version
> > gcc (GCC) 4.1.2 20061115 (prerelease) (Debian 4.1.1-21)

Looks like a bug where __initdata has been used
for const data.
Searching:
static int __devinit sis190_get_mac_addr_from_apc(struct pci_dev *pdev,
                                                  struct net_device *dev)
{
        static const u16 __devinitdata ids[] = { 0x0965, 0x0966, 0x0968 };
        struct sis190_private *tp = netdev_priv(dev);
        struct pci_dev *isa_bridge;
        u8 reg, tmp8;

Try to change this is __initconst and it should be fixed.

	Sam
