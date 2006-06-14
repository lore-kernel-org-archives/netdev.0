From: Valerie Henson <val_henson@linux.intel.com>
Subject: Re: PATCHv3 2.6.17-rc5 tulip free_irq() called too late
Date: Tue, 13 Jun 2006 17:06:18 -0700
Message-ID: <20060614000618.GL12533@goober>
References: <20060531195234.GA4967@colo.lackof.org> <44883778.8000209@pobox.com> <20060608170120.GI8246@colo.lackof.org> <20060613235531.GA4191@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr17.intel.com ([134.134.136.16]:62915 "EHLO
	orsfmr002.jf.intel.com") by vger.kernel.org with ESMTP
	id S932330AbWFNAHh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 20:07:37 -0400
To: Grant Grundler <grundler@parisc-linux.org>
Content-Disposition: inline
In-Reply-To: <20060613235531.GA4191@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 13, 2006 at 05:55:31PM -0600, Grant Grundler wrote:
> On Thu, Jun 08, 2006 at 11:01:20AM -0600, Grant Grundler wrote:
> > Here is a new patch that moves free_irq() into tulip_down().
> > The resulting code is structured the same as cp_close().
> 
> Val,
> Two details are wrong in version 2 and are fixed in v3 (appended below):
> 
> o we don't need synchronize_irq() before calling free_irq().
>   (It should be removed from cp_close() too)
>   Thanks to willy for pointing me at kernel/irq/manage.c.
> 
> o tulip_stop_rxtx() has to be called _after_ free_irq().
>   ie. v2 patch didn't fix the original race condition
>   and when under test, dies about as fast as the original code.
> 
> Tested on rx4640 (HP IA64) for several hours.
> Please apply.

Thanks, I'll take a look next week (after the workshop and moving).

-VAL
