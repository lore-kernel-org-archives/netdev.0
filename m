From: Bjorn Helgaas <helgaas@kernel.org>
Subject: Re: Legacy features in PCI Express devices
Date: Mon, 13 Mar 2017 13:55:04 -0500
Message-ID: <20170313185504.GC8232@bhelgaas-glaptop.roam.corp.google.com>
References: <ef5c9778-fbae-9f4f-ac2e-29b8597537a5@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-pci <linux-pci@vger.kernel.org>,
        David Laight <david.laight@aculab.com>,
        Robin Murphy <robin.murphy@arm.com>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>,
        Phuong Nguyen <phuong_nguyen@sigmadesigns.com>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>,
        netdev <netdev@vger.kernel.org>,
        Tim Harvey <tharvey@gateworks.com>,
        Arnd Bergmann <arnd@arndb.de>
To: Mason <slash.tmp@free.fr>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <ef5c9778-fbae-9f4f-ac2e-29b8597537a5@free.fr>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 13, 2017 at 05:10:57PM +0100, Mason wrote:
> Hello,
> 
> There are two revisions of our PCI Express controller.
> 
> Rev 1 did not support the following features:
> 
>   1) legacy PCI interrupt delivery (INTx signals)
>   2) I/O address space
> 
> Internally, someone stated that such missing support would prevent
> some PCIe cards from working with our controller.
> 
> Are there really modern PCIe cards that require 1) and/or 2)
> to function?

>From a spec point of view, all endpoints, including Legacy, PCI
Express, and Root Complex Integrated Endpoints, are "required to
support MSI or MSI-X or both if an interrupt resource is requested"
(PCIe r3.0, sec 1.3.2).

The same section says Legacy Endpoints are permitted to use I/O
Requests, but PCI Express and Root Complex Integrated Endpoints are
not.  There's a little wiggle room in the I/O BAR description; I would
interpret it to mean the latter two varieties are permitted to have
I/O BARs, but they must make the resources described by those BARs
available via a memory BAR as well, so they can operate with I/O
address space.

But that's only in theory; David has already given examples of devices
that don't support MSI, and Greg hinted at new devices that might
require I/O space.  I'm particularly curious about that last one,
because there are several host bridges that don't support I/O space at
all.

Bjorn
