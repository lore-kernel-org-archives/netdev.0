From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [PATCH 0/3] add support for Janz MODULbus devices
Date: Fri, 2 Apr 2010 12:00:05 +0200
Message-ID: <20100402100004.GB8010@sortiz.org>
References: <>
 <1269881932-3803-1-git-send-email-iws@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, socketcan-core@lists.berlios.de,
	netdev@vger.kernel.org
To: "Ira W. Snyder" <iws@ovro.caltech.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1269881932-3803-1-git-send-email-iws@ovro.caltech.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ira,

On Mon, Mar 29, 2010 at 09:58:49AM -0700, Ira W. Snyder wrote:
> This patch series adds support for the Janz CMOD-IO carrier board, as well
> as the Janz VMOD-ICAN3 Intelligent CAN controller and the Janz VMOD-TTL
> Digital IO controller. The CMOD-IO carrier board is a PCI to MODULbus
> bridge, into which plug MODULbus daughterboards.  I only have access to two
> types of daughtercards, the VMOD-ICAN3 and VMOD-TTL boards mentioned above.
> 
> The CAN driver has been tested under high loads. I am able to generate ~60%
> bus utilization. With two VMOD-ICAN3 boards looped back to each other,
> neither one loses any packets when only a single board is generating
> packets at maximum speed. Once both boards start generating packets, one
> board will sometimes loose arbitration, and cause some lost packets.
> 
> After much review from the last posting of the series, I believe that this
> should be ready for mainline. Many thanks to everyone that helped!
All 3 patches applied, thanks a lot.
After talking with Jesse Barnes (PCI maintainer), I moved the JANZ PCI id back
to the mfd driver. Jesse was saying that when a PCI id is used by only one
driver, it should be defined there and not in pci_ids.h. Sorry for the
mislead.

Cheers,
Samuel.


> RFCv4 -> RFCv5:
> - removed some dev_dbg() statements
> - change default MODULbus modules to "none"
> - accept both "empty" and "" in the MODULbus modules parameter
> - print an error message when no MODULbus modules are specified
> - add sysfs support to get/set CAN bus termination
> - fix error-active and error-passive state reporting
> - add support for netlink bus-error messages
> - fixed sparse warnings
> - used mfd-core API for multifunction device probing
> 
> RFCv3 -> RFCv4:
> - addressed many review comments
> - switch to NAPI
> - add TX flow control
> - mark functions with __devinit and __devexit
> - add sysfs readout of MODULbus number (hex switch)
> - implement GPIO driver for VMOD-TTL
> 
> RFCv2 -> RFCv3:
> - addressed many review comments
> - correct CAN bus error handling
> - use struct device to track subdevices
> - use structures for register layout
> - add lots of #defines for register values
> - use better function prefixes
> 
> RFCv1 -> RFCv2:
> - converted to a multi-driver model
> - addressed many review comments
> - added CAN bus error handling
> - use a work function only instead of work + NAPI
> - use SJA1000 bittiming calculation code
> 
> Thanks,
> Ira

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
