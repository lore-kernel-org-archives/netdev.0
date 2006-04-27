From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Subject: Re: [patch 7/9] e100: disable interrupts at boot
Date: Thu, 27 Apr 2006 09:05:47 -0600
Message-ID: <200604270905.47774.bjorn.helgaas@hp.com>
References: <200604270932.k3R9WBhr025327@shell0.pdx.osdl.net> <44509628.4090704@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	nils.rennebarth@packetalarm.com, stern@rowland.harvard.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:60307 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S965141AbWD0PFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 11:05:53 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <44509628.4090704@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 27 April 2006 04:00, Jeff Garzik wrote:
> akpm@osdl.org wrote:
> > From: Bjorn Helgaas <bjorn.helgaas@hp.com>
> > 
> > Apparently the Intel PRO/100 device enables interrupts on reset.  Unless
> > firmware explicitly disables PRO/100 interrupts, we can get a flood of
> > interrupts when a driver attaches to an unrelated device that happens to
> > share the PRO/100 IRQ.
> > 
> > This should resolve this "irq 11: nobody cared" bug report:
> >     http://bugzilla.kernel.org/show_bug.cgi?id=5918
> > 
> > Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
> > Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> > Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Cc: John Ronciak <john.ronciak@intel.com>
> > Cc: <stern@rowland.harvard.edu>
> > Cc: <nils.rennebarth@packetalarm.com>
> > Signed-off-by: Andrew Morton <akpm@osdl.org>
> 
> I'm really worried that we are burdening the kernel for a very very rare 
> condition.  Do we want to apply this for one stupid firmware?
> 
> Can't early userspace just run setpci to fix this one?

I don't think so, because the problem occurs as soon as any driver
enables IRQ 11.  I agree that it's rare, but it's a real pain to
debug it and identify it when it occurs.
