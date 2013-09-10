From: Vladimir Murzin <murzin.v@gmail.com>
Subject: Re: [PATCH] pch_gbe: fix unmet direct dependency on
 PTP_1588_CLOCK_PCH
Date: Tue, 10 Sep 2013 04:29:38 +0200
Message-ID: <20130910022936.GA3630@hp530>
References: <1378754910-2254-1-git-send-email-murzin.v@gmail.com>
 <522E28E5.5010106@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, davem@davemloft.net, ben@decadent.org.uk,
	jeffrey.t.kirsher@intel.com, rdunlap@xenotime.net,
	haicheng.lee@gmail.com
To: Randy Dunlap <rdunlap@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:63059 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751638Ab3IJCaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 22:30:12 -0400
Received: by mail-la0-f53.google.com with SMTP id el20so5485315lab.26
        for <netdev@vger.kernel.org>; Mon, 09 Sep 2013 19:30:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <522E28E5.5010106@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 09, 2013 at 01:00:37PM -0700, Randy Dunlap wrote:
> On 09/09/13 12:28, Vladimir Murzin wrote:
> > While cross-building for PPC.
> > 
> > warning: (PCH_GBE) selects PTP_1588_CLOCK_PCH which has unmet direct
> > dependencies (X86 || COMPILE_TEST)
> > 
> > Both PCH_GBE and PPT_1588_CLOCK_PCH is only compatible with Intel
> > architecture. Add dependency on x86 for PCH_GBE. Keep COMPILE_TEST to allow
> > building on different arches.
> > 
> > Signed-off-by: Vladimir Murzin <murzin.v@gmail.com>
> > ---
> >  drivers/net/ethernet/oki-semi/pch_gbe/Kconfig | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
> > index cb22341..4a935ec 100644
> > --- a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
> > +++ b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
> > @@ -4,7 +4,7 @@
> >  
> >  config PCH_GBE
> >  	tristate "OKI SEMICONDUCTOR IOH(ML7223/ML7831) GbE"
> > -	depends on PCI
> > +	depends on PCI && (x86 || COMPILE_TEST)
> 
> Has this been tested?
> That should be             X86

Right, it should be X86. It was cross-compile tested which was obviously not
enough. Thanks.

> 
> >  	select MII
> >  	select PTP_1588_CLOCK_PCH
> >  	---help---
> > 
> 
> 
> -- 
> ~Randy
