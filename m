From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH 1/7] pci: Add PCI LRDT tag size and section size
Date: Thu, 25 Feb 2010 11:48:28 -0800
Message-ID: <20100225194828.GA6309@xw6200.broadcom.net>
References: <1267121962-6077-2-git-send-email-mcarlson@broadcom.com>
 <20100225105345.0baadeb4@nehalam>
 <20100225191110.GA6231@xw6200.broadcom.net>
 <1267126561.2107.13.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"Stephen Hemminger" <shemminger@vyatta.com>,
	"jbarnes@virtuousgeek.org" <jbarnes@virtuousgeek.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"andy@greyhouse.net" <andy@greyhouse.net>,
	"Michael Chan" <mchan@broadcom.com>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3203 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933439Ab0BYTsh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2010 14:48:37 -0500
In-Reply-To: <1267126561.2107.13.camel@achroite.uk.solarflarecom.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 25, 2010 at 11:36:01AM -0800, Ben Hutchings wrote:
> On Thu, 2010-02-25 at 11:11 -0800, Matt Carlson wrote:
> > On Thu, Feb 25, 2010 at 10:53:45AM -0800, Stephen Hemminger wrote:
> [...]
> > > Shouldn't the function take the pci resource not just the register.
> > 
> > The functions are designed to operate on a buffer of VPD data, not from
> > the hardware directly.
> > 
> > > And finally, how common is this or is it just something unique to your hw.
> > 
> > The VPD area is defined by the PCI specs, in the section noted in the
> > comment above.  The definitions and functions introduced in this patchset
> > should be usable by any driver.  I stopped short of modifying other
> > drivers, but I certainly could have.
> > 
> > However, there are two approaches taken as to how the VPD data is
> > extracted and used.  Drivers like tg3 and bnx2 load the VPD data into
> > a buffer and operate on that.  Other drivers like niu navigate the VPD
> > by loading a dword at a time.  This API would cover the former
> > implementation which I've only found to be used by the tg3 and bnx2
> > drivers so far.
> 
> VPD *access* can be done generically through pci_read_vpd() and
> pci_write_vpd(), which use struct pci_vpd_ops.  Currently the only
> implementation of pci_vpd_ops is for standard PCI 2.2 VPD.  Other
> implementations could be provided for PCI 2.1 VPD or non-standard access
> methods.
> 
> VPD *parsing* is currently left to user-space (lspci etc.) and to a few
> drivers that need it for some reason.
> 
> I notice that bnx2 and tg3 are not using pci_read_vpd().  Presumably
> this is an optimisation?

The tg3 driver does use pci_read_vpd() for those cases where
(magic != TG3_EEPROM_MAGIC).  But yes, it is an optimization.

