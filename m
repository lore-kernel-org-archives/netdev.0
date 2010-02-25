From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/7] pci: Add PCI LRDT tag size and section size
Date: Thu, 25 Feb 2010 19:36:01 +0000
Message-ID: <1267126561.2107.13.camel@achroite.uk.solarflarecom.com>
References: <1267121962-6077-2-git-send-email-mcarlson@broadcom.com>
	 <20100225105345.0baadeb4@nehalam>
	 <20100225191110.GA6231@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"jbarnes@virtuousgeek.org" <jbarnes@virtuousgeek.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"andy@greyhouse.net" <andy@greyhouse.net>,
	Michael Chan <mchan@broadcom.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:27489 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932792Ab0BYTgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 14:36:05 -0500
In-Reply-To: <20100225191110.GA6231@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-02-25 at 11:11 -0800, Matt Carlson wrote:
> On Thu, Feb 25, 2010 at 10:53:45AM -0800, Stephen Hemminger wrote:
[...]
> > Shouldn't the function take the pci resource not just the register.
> 
> The functions are designed to operate on a buffer of VPD data, not from
> the hardware directly.
> 
> > And finally, how common is this or is it just something unique to your hw.
> 
> The VPD area is defined by the PCI specs, in the section noted in the
> comment above.  The definitions and functions introduced in this patchset
> should be usable by any driver.  I stopped short of modifying other
> drivers, but I certainly could have.
> 
> However, there are two approaches taken as to how the VPD data is
> extracted and used.  Drivers like tg3 and bnx2 load the VPD data into
> a buffer and operate on that.  Other drivers like niu navigate the VPD
> by loading a dword at a time.  This API would cover the former
> implementation which I've only found to be used by the tg3 and bnx2
> drivers so far.

VPD *access* can be done generically through pci_read_vpd() and
pci_write_vpd(), which use struct pci_vpd_ops.  Currently the only
implementation of pci_vpd_ops is for standard PCI 2.2 VPD.  Other
implementations could be provided for PCI 2.1 VPD or non-standard access
methods.

VPD *parsing* is currently left to user-space (lspci etc.) and to a few
drivers that need it for some reason.

I notice that bnx2 and tg3 are not using pci_read_vpd().  Presumably
this is an optimisation?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

