From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: PATCHv3 2.6.17-rc5 tulip free_irq() called too late
Date: Fri, 16 Jun 2006 09:25:49 -0600
Message-ID: <20060616152549.GB7868@colo.lackof.org>
References: <20060613235531.GA4191@colo.lackof.org> <448F5952.1060201@pobox.com> <20060614044412.GA30552@colo.lackof.org> <44902554.7010703@pobox.com> <20060614181419.GA10365@colo.lackof.org> <20060614204720.GA17887@electric-eye.fr.zoreil.com> <20060614223021.GB13212@colo.lackof.org> <20060615203017.GA6724@electric-eye.fr.zoreil.com> <20060616054711.GA28524@colo.lackof.org> <44925EA8.5070906@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <grundler@parisc-linux.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Valerie Henson <val_henson@linux.intel.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:18643 "EHLO colo.lackof.org")
	by vger.kernel.org with ESMTP id S1751451AbWFPPZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2006 11:25:51 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <44925EA8.5070906@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 16, 2006 at 03:32:56AM -0400, Jeff Garzik wrote:
> >Correct. Before calling free_irq(), patch V3 masks interrupts on tulip
> >and guarantees the tulip will not generate new interrupts before that call.
> 
> Incorrect -- it does not guarantee that tulip will not generate new 
> interrupt events.

Are you saying the following sequence doesn't mask tulip interrupts?

        /* Disable interrupts by clearing the interrupt mask. */
        iowrite32 (0x00000000, ioaddr + CSR7);
        ioread32 (ioaddr + CSR7);       /* flush posted write */

Secondly, since you've ignored the two previous times I've asked,
I'll assume you agree tulip driver has to (and does) handle
the case of pending, masked interrupts at initialization because
firmware might leave it in that state.

thanks,
grant
