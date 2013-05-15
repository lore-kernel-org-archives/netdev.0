From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: BCM5719(tg3) use multiple MSI with RSS
Date: Wed, 15 May 2013 16:52:00 +0100
Message-ID: <1368633120.2652.11.camel@bwh-desktop.uk.solarflarecom.com>
References: <51933FCB.4090402@linux.vnet.ibm.com>
	 <1368630538.3768.12.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mike Qiu <qiudayu@linux.vnet.ibm.com>, <eilong@broadcom.com>,
	<mcarlson@broadcom.com>, <zambrano@broadcom.com>,
	<jeffrey.t.kirsher@intel.com>, <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:57848 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758111Ab3EOPwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 11:52:08 -0400
In-Reply-To: <1368630538.3768.12.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-15 at 08:08 -0700, Michael Chan wrote:
> On Wed, 2013-05-15 at 15:56 +0800, Mike Qiu wrote: 
> > Hi all
> > 
> > Currently, I need to enable multiple MSI on BCM5719 network card.
> > But I look in to the spec of 5719 from Broadcom, it seems
> > that RSS just enable with MSI-X, so I'm not sure if multiple
> > MSI can use RSS.
> > 
> 
> MSI can only support one IRQ source and cannot support RSS.

It is possible for an MSI capability to have multiple MSIs, but they
will use the same address and consecutive data values.

On x86, if you can find a large enough block of free IRQs on an IOAPIC,
it is possible to implement RSS this way.  Linux supports this on
systems with an x2apic.

Now, maybe tg3 hardware doesn't support this (and really, why bother
when there is MSI-X?) but the option does exist.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
