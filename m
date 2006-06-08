From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 1/2] e1000: fix netpoll with NAPI
Date: Thu, 8 Jun 2006 14:39:03 -0400
Message-ID: <20060608183857.GA16733@tuxdriver.com>
References: <4485B8EC.4090603@intel.com> <x494pyyw5sr.fsf@segfault.boston.redhat.com> <4485BCA2.5070904@intel.com> <x49zmgquqn0.fsf@segfault.boston.redhat.com> <20060606231727.GK24227@waste.org> <20060607150522.GA24608@hmsreliant.homelinux.net> <20060607164801.GX24227@waste.org> <44871A19.7080805@intel.com> <20060607185440.GC26702@tuxdriver.com> <1149787436.2928.9.camel@strongmad>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	Matt Mackall <mpm@selenic.com>,
	"Garzik, Jeff" <jgarzik@pobox.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jeff Moyer <jmoyer@redhat.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:15116 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S964933AbWFHSjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 14:39:31 -0400
To: Mitch Williams <mitch.a.williams@intel.com>
Content-Disposition: inline
In-Reply-To: <1149787436.2928.9.camel@strongmad>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 08, 2006 at 10:23:56AM -0700, Mitch Williams wrote:
> On Wed, 2006-06-07 at 11:54 -0700, John W. Linville wrote:
> 
> > Pedantic objection, but I think this would read easier w/o the extra
> > newline before disable_irq.
> 
> Heh.  I prefer to have a newline between declarations and code.  The

Normally I would agree.  But in this case, I find the distraction of
the random newline after the #else to be more compelling.

> real problem is the position of the #ifdef -- that's what makes it
> difficult to read.  The other solution would be
> {
>         struct e1000_adapter *adapter = netdev_priv(netdev);
> #ifdef CONFIG_E1000_NAPI
> 	int budget = 0;
> #endif
> 
> 	disable_irq(adapter->pdev->irq);
> 
> #ifdef CONFIG_E1000_NAPI
> 	< all that stuff >
> #else
> 	<rest of the stuff >
> #endif
> }
> 
> Which I think is worse to read.

I presume it is the double #ifdef that you find objectionable?
I don't really like it, but at least that idiom is quite common.

Given that the disable_irq appears in both code paths (almost by
necessity), there is a certain appeal to having it outside of the
#ifdef block.  That seems more maintainable.

To me, the idiomatic #ifdef placement seems more readable, if for no
other reason than familiarity.  I suppose we can agree to disagree.

John
-- 
John W. Linville
linville@tuxdriver.com
