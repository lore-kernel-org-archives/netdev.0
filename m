From: "Leonid Grossman" <Leonid.Grossman@neterion.com>
Subject: RE: [ANNOUNCE] New driver vxge for Neterion's X3100 series10GbEPCIe adapter
Date: Wed, 1 Apr 2009 01:44:45 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77051BF05A@nekter>
References: <1237018825.4966.412.camel@flash> <20090331061333.GA11240@yzhao-otc.sh.intel.com> <78C9135A3D2ECE4B8162EBDCE82CAD77051BEEA1@nekter> <49D257D0.9050104@intel.com> <78C9135A3D2ECE4B8162EBDCE82CAD77051BF027@nekter> <20090401025327.GA11687@yzhao-otc.sh.intel.com> <78C9135A3D2ECE4B8162EBDCE82CAD77051BF03C@nekter> <20090401050940.GB11687@yzhao-otc.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Netdev" <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
To: "Yu Zhao" <yu.zhao@intel.com>,
	"Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:19708 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752418AbZDAFqV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 01:46:21 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20090401050940.GB11687@yzhao-otc.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Yu Zhao [mailto:yu.zhao@intel.com]
> Sent: Tuesday, March 31, 2009 10:10 PM
> To: Ramkrishna Vepa
> Cc: Duyck, Alexander H; Leonid Grossman; Netdev; David Miller
> Subject: Re: [ANNOUNCE] New driver vxge for Neterion's X3100
> series10GbEPCIe adapter
> 
> On Wed, Apr 01, 2009 at 11:36:11AM +0800, Ramkrishna Vepa wrote:
> > > Yes, and that's what the PCI subsystem does. If the vxge VF is
> > identical
> > > to its PF, then vxge should be able to drive both PF and VF
without
> > any
> > > modification.
> > [Ram] Ok. In that case, is the call to pci_enable/disable_sriov
still
> > required for vxge?
> 
> Yes, the vxge driver first binds the PF once it's loaded (VF doesn't
> exist at this time) and calls the SR-IOV API. The VF appears after the
> SR-IOV is enabled and then the same copy of the vxge driver can bind
> the VF too if you want to use the VF in the native Linux. Though the
> hardware is in the SR-IOV mode in this case, it would be equal to the
> multi-function mode. Or you can assign the VF to the Xen/KVM guest and
> let another copy of vxge driver (may be vxge for Windows, Solaris,
BSD,
> etc.) running in the guest bind it.

Yu, could you pl. explain why this call is not optional - SR-IOV pci-e
code should be able to find SR-IOV capable device and enable all VFs
based upon pci-e config space alone, without any help from
device-specific PF driver.
Once VFs appear, vxge or any other native netdev driver should be able
to bind a VF regardless of PF driver being loaded first (or at all) -
there are some use cases that do not assume PF driver presence...
Thanks, Leonid 

> 
> Thanks,
> Yu
