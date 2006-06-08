From: Mitch Williams <mitch.a.williams@intel.com>
Subject: Re: [PATCH 1/2] e1000: fix netpoll with NAPI
Date: Thu, 08 Jun 2006 10:23:56 -0700
Message-ID: <1149787436.2928.9.camel@strongmad>
References: <1149611965.13635.19.camel@strongmad>
	 <20060606170513.GB21969@hmsreliant.homelinux.net>
	 <4485B8EC.4090603@intel.com> <x494pyyw5sr.fsf@segfault.boston.redhat.com>
	 <4485BCA2.5070904@intel.com> <x49zmgquqn0.fsf@segfault.boston.redhat.com>
	 <20060606231727.GK24227@waste.org>
	 <20060607150522.GA24608@hmsreliant.homelinux.net>
	 <20060607164801.GX24227@waste.org> <44871A19.7080805@intel.com>
	 <20060607185440.GC26702@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	Matt Mackall <mpm@selenic.com>,
	"Garzik, Jeff" <jgarzik@pobox.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jeff Moyer <jmoyer@redhat.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:29622 "EHLO
	azsmga101-1.ch.intel.com") by vger.kernel.org with ESMTP
	id S964916AbWFHRYB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jun 2006 13:24:01 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060607185440.GC26702@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-06-07 at 11:54 -0700, John W. Linville wrote:

> Pedantic objection, but I think this would read easier w/o the extra
> newline before disable_irq.

Heh.  I prefer to have a newline between declarations and code.  The
real problem is the position of the #ifdef -- that's what makes it
difficult to read.  The other solution would be
{
        struct e1000_adapter *adapter = netdev_priv(netdev);
#ifdef CONFIG_E1000_NAPI
	int budget = 0;
#endif

	disable_irq(adapter->pdev->irq);

#ifdef CONFIG_E1000_NAPI
	< all that stuff >
#else
	<rest of the stuff >
#endif
}

Which I think is worse to read.
-Mitch
