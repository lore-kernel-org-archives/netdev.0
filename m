From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH 1/7] pci: Add PCI LRDT tag size and section size
Date: Thu, 25 Feb 2010 11:11:10 -0800
Message-ID: <20100225191110.GA6231@xw6200.broadcom.net>
References: <1267121962-6077-2-git-send-email-mcarlson@broadcom.com>
 <20100225105345.0baadeb4@nehalam>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"jbarnes@virtuousgeek.org" <jbarnes@virtuousgeek.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"andy@greyhouse.net" <andy@greyhouse.net>,
	"Michael Chan" <mchan@broadcom.com>
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20100225105345.0baadeb4@nehalam>
Content-Disposition: inline
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 25, 2010 at 10:53:45AM -0800, Stephen Hemminger wrote:
> On Thu, 25 Feb 2010 10:19:16 -0800
> "Matt Carlson" <mcarlson@broadcom.com> wrote:
> 
> > +++ b/include/linux/pci-vpd.h
> > @@ -0,0 +1,26 @@
> > +/*
> > + *	pci-vpd.h
> > + *
> > + *	PCI VPD defines and function prototypes
> > + *
> > + *	Copyright (C) 2010 Broadcom Corporation.
> > + *
> > + *	For more information, please consult the following manuals (look at
> > + *	http://www.pcisig.com/ for how to get them):
> > + *
> > + *	PCI Local Bus Specification, Rev. 3.0 : Appendix I
> > + */
> > +
> > +#ifndef LINUX_PCI_VPD_H
> > +#define LINUX_PCI_VPD_H
> > +
> > +#include <linux/pci.h>
> > +
> > +#define PCI_VPD_LRDT_TAG_SIZE	3
> > +
> > +static inline u16 pci_vpd_lrdt_size(u8 *lrdt)
> > +{
> > +	return (u16)lrdt[1] + ((u16)lrdt[2] << 8);
> > +}
> > +
> > +#endif /* LINUX_PCI_VPD_H */
> > -- 
> 
> No need for new file for this, it should be part of existing pci.h

O.K.  I'll make the change.

> Also need kernel doc format comment to describe usage.

O.K.

> Shouldn't the function take the pci resource not just the register.

The functions are designed to operate on a buffer of VPD data, not from
the hardware directly.

> And finally, how common is this or is it just something unique to your hw.

The VPD area is defined by the PCI specs, in the section noted in the
comment above.  The definitions and functions introduced in this patchset
should be usable by any driver.  I stopped short of modifying other
drivers, but I certainly could have.

However, there are two approaches taken as to how the VPD data is
extracted and used.  Drivers like tg3 and bnx2 load the VPD data into
a buffer and operate on that.  Other drivers like niu navigate the VPD
by loading a dword at a time.  This API would cover the former
implementation which I've only found to be used by the tg3 and bnx2
drivers so far.
