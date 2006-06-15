From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: PATCHv3 2.6.17-rc5 tulip free_irq() called too late
Date: Thu, 15 Jun 2006 22:30:17 +0200
Message-ID: <20060615203017.GA6724@electric-eye.fr.zoreil.com>
References: <20060531195234.GA4967@colo.lackof.org> <44883778.8000209@pobox.com> <20060608170120.GI8246@colo.lackof.org> <20060613235531.GA4191@colo.lackof.org> <448F5952.1060201@pobox.com> <20060614044412.GA30552@colo.lackof.org> <44902554.7010703@pobox.com> <20060614181419.GA10365@colo.lackof.org> <20060614204720.GA17887@electric-eye.fr.zoreil.com> <20060614223021.GB13212@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Valerie Henson <val_henson@linux.intel.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:40403 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1031276AbWFOUdb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jun 2006 16:33:31 -0400
To: Grant Grundler <grundler@parisc-linux.org>
Content-Disposition: inline
In-Reply-To: <20060614223021.GB13212@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Grant Grundler <grundler@parisc-linux.org> :
[shared irq]
> I thought we've worked through that already:
> 	http://www.spinics.net/lists/netdev/msg05902.html
> 
> Patch v3 takes care of that problem.
> The first step in the sequence is to mask IRQs on the tulip.
> The "neighbor" device sharing the IRQ will not see any interrupts from
> the tulip after that.

Afaik free_irq() on a shared irq does not touch the hardware and
irqs are anything but synchronous. If free_irq() is issued before
the device is idle and its irq are not acked, it's wrong.

-- 
Ueimor
