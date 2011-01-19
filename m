From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH] xen network backend driver
Date: Wed, 19 Jan 2011 19:24:24 +0000
Message-ID: <1295465064.3693.75.camel@localhost.localdomain>
References: <1295449318.14981.3484.camel@zakaz.uk.xensource.com>
	 <1295455216.11126.39.camel@bwh-desktop>
	 <1295459316.14981.3727.camel@zakaz.uk.xensource.com>
	 <1295460304.11126.53.camel@bwh-desktop>  <4D3738AB.60701@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	"Konrad Rzeszutek Wilk" <konrad.wilk@oracle.com>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:31916 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753108Ab1ASTY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 14:24:28 -0500
In-Reply-To: <4D3738AB.60701@goop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-01-19 at 19:16 +0000, Jeremy Fitzhardinge wrote: 
> On 01/19/2011 10:05 AM, Ben Hutchings wrote:
> > Not in itself.  NAPI polling will run on the same CPU which scheduled it
> > (so wherever the IRQ was initially handled).  If the protocol used
> > between netfront and netback doesn't support RSS then RPS
> > <http://lwn.net/Articles/362339/> can be used to spread the RX work
> > across CPUs.
> 
> There's only one irq per netback which is bound to one (V)CPU at a
> time.  I guess we could extend it to have multiple irqs per netback and
> some way of distributing packet flows over them, but that would only
> really make sense if there's a single interface with much more traffic
> than the others; otherwise the interrupts should be fairly well
> distributed (assuming that the different netback irqs are routed to
> different cpus).

I'd gotten myself confused thinking in terms of a single driver -- this
all just falls out naturally from each vif backend instance having its
own interrupt, just like it does today, NAPI makes no difference here.

There is talk of implementing multiqueue (and hence multi-IRQ) support
for the guest RX path (netback TX) and using RSS in that case but not
yet any plans for anything similar on the guest TX path.

Ian.

