From: Jon Mason <jon.mason@intel.com>
Subject: Re: [RFC v3 1/2] PCI-Express Non-Transparent Bridge Support
Date: Fri, 21 Sep 2012 16:45:59 -0700
Message-ID: <20120921234558.GA6531@jonmason-lab>
References: <1348250989-6962-1-git-send-email-jon.mason@intel.com>
 <1348250989-6962-2-git-send-email-jon.mason@intel.com>
 <20120921.141447.1146043198575242769.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, dave.jiang@intel.com,
	nab@risingtidesystems.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120921.141447.1146043198575242769.davem@davemloft.net>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 21, 2012 at 02:14:47PM -0400, David Miller wrote:
> From: Jon Mason <jon.mason@intel.com>
> Date: Fri, 21 Sep 2012 11:09:48 -0700
> 
> > A PCI-Express non-transparent bridge (NTB) is a point-to-point PCIe bus
> > connecting 2 systems, providing electrical isolation between the two subsystems.
> > A non-transparent bridge is functionally similar to a transparent bridge except
> > that both sides of the bridge have their own independent address domains.  The
> > host on one side of the bridge will not have the visibility of the complete
> > memory or I/O space on the other side of the bridge.  To communicate across the
> > non-transparent bridge, each NTB endpoint has one (or more) apertures exposed to
> > the local system.  Writes to these apertures are mirrored to memory on the
> > remote system.  Communications can also occur through the use of doorbell
> > registers that initiate interrupts to the alternate domain, and scratch-pad
> > registers accessible from both sides.
> > 
> > The NTB device driver is needed to configure these memory windows, doorbell, and
> > scratch-pad registers as well as use them in such a way as they can be turned
> > into a viable communication channel to the remote system.  ntb_hw.[ch]
> > determines the usage model (NTB to NTB or NTB to Root Port) and abstracts away
> > the underlying hardware to provide access and a common interface to the doorbell
> > registers, scratch pads, and memory windows.  These hardware interfaces are
> > exported so that other, non-mainlined kernel drivers can access these.
> > ntb_transport.[ch] also uses the exported interfaces in ntb_hw.[ch] to setup a
> > communication channel(s) and provide a reliable way of transferring data from
> > one side to the other, which it then exports so that "client" drivers can access
> > them.  These client drivers are used to provide a standard kernel interface
> > (i.e., Ethernet device) to NTB, such that Linux can transfer data from one
> > system to the other in a standard way.
> > 
> > Signed-off-by: Jon Mason <jon.mason@intel.com>
> 
> I really don't see anything that requires the TX networking processing
> to occur in a tasklet.  I see no sleeping, strange locking, or
> anything like that.
> 
> And if that's the case, it's just pure overhead.

Good point.  Removed (and I see a nice little perf bump).

Thanks,
Jon
