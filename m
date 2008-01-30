From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: sis190 build breakage
Date: Wed, 30 Jan 2008 10:13:27 +0100
Message-ID: <20080130091327.GA20178@uranus.ravnborg.org>
References: <20080129215023.GA24152@stro.at> <20080129220310.GC15445@electric-eye.fr.zoreil.com> <20080130032838.GA17881@uranus.ravnborg.org> <47A033DB.3070608@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	maximilian attems <max@stro.at>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>, Jan Beulich <jbeulich@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpb.tele.dk ([80.160.77.98]:36500 "EHLO pasmtpB.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751288AbYA3JNe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 04:13:34 -0500
Content-Disposition: inline
In-Reply-To: <47A033DB.3070608@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 30, 2008 at 03:22:51AM -0500, Jeff Garzik wrote:
> Sam Ravnborg wrote:
> >On Tue, Jan 29, 2008 at 11:03:10PM +0100, Francois Romieu wrote:
> >>maximilian attems <max@stro.at> :
> >>>  CC [M]  drivers/net/sis190.o
> >>>  drivers/net/sis190.c:329: error: sis190_pci_tbl causes a section type 
> >>>  conflict
> >>>  make[5]: *** [drivers/net/sis190.o] Error 1
> >>>
> >>>gcc --version
> >>>gcc (GCC) 4.1.2 20061115 (prerelease) (Debian 4.1.1-21)
> >
> >Looks like a bug where __initdata has been used
> >for const data.
> >Searching:
> >static int __devinit sis190_get_mac_addr_from_apc(struct pci_dev *pdev,
> >                                                  struct net_device *dev)
> >{
> >        static const u16 __devinitdata ids[] = { 0x0965, 0x0966, 0x0968 };
> >        struct sis190_private *tp = netdev_priv(dev);
> >        struct pci_dev *isa_bridge;
> >        u8 reg, tmp8;
> >
> >Try to change this is __initconst and it should be fixed.
> 
> We have __initconst now?
> 
> Three cheers, and a beer, to whomever did that...
I will hand over the cheers to Jan Beulich and drink the beer myself ;-)

	Sam
