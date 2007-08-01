From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] prevent SSB compilation on s390 part 2
Date: Wed, 1 Aug 2007 16:54:36 +0200
Message-ID: <200708011654.37588.mb@bu3sch.de>
References: <20070731230932.a9459617.akpm@linux-foundation.org> <20070801093404.GA12124@osiris.boeblingen.de.ibm.com> <20070801144308.GC12124@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Jeff Garzik <jeff@garzik.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:47943
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932218AbXHAOyq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2007 10:54:46 -0400
In-Reply-To: <20070801144308.GC12124@osiris.boeblingen.de.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 01 August 2007, Heiko Carstens wrote:
> On Wed, Aug 01, 2007 at 11:34:04AM +0200, Heiko Carstens wrote:
> > From: Heiko Carstens <heiko.carstens@de.ibm.com>
> > 
> > drivers/ssb/Kconfig has already a depends on HAS_IOMEM which should
> > prevent SSB from being selected. But appearantly it looks like this
> > doesn't matter at all if it gets selected from somewhere else.
> > So add an explicit depends on HAS_IOMEM to the Broadcom driver to
> > prevent selection on s390.
> > 
> > Cc: "John W. Linville" <linville@tuxdriver.com>
> > Cc: Michael Buesch <mb@bu3sch.de>
> > Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> > Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> > ---
> >  drivers/net/Kconfig |    1 +
> >  1 files changed, 1 insertion(+)
> > 
> > Index: linux-2.6.22/drivers/net/Kconfig
> > ===================================================================
> > --- linux-2.6.22.orig/drivers/net/Kconfig
> > +++ linux-2.6.22/drivers/net/Kconfig
> > @@ -1434,6 +1434,7 @@ config APRICOT
> > 
> >  config B44
> >  	tristate "Broadcom 440x/47xx ethernet support"
> > +	depends on HAS_IOMEM
> >  	select SSB
> >  	select MII
> >  	help
> 
> By the way.. wouldn't something like depends on NET_PCI or something
> similar more correct for this driver? Just wondering...
> 
> 

No, B44 does not depend on PCI. It does depend on the SSB bus.
(Of course the SSB PCI parts do depend on PCI)
