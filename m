From: Yu Zhao <yu.zhao@intel.com>
Subject: Re: [ANNOUNCE] New driver vxge for Neterion's X3100 series 10
	GbEPCIe adapter
Date: Wed, 1 Apr 2009 10:53:27 +0800
Message-ID: <20090401025327.GA11687@yzhao-otc.sh.intel.com>
References: <1237018825.4966.412.camel@flash> <20090331061333.GA11240@yzhao-otc.sh.intel.com> <78C9135A3D2ECE4B8162EBDCE82CAD77051BEEA1@nekter> <49D257D0.9050104@intel.com> <78C9135A3D2ECE4B8162EBDCE82CAD77051BF027@nekter>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Leonid Grossman <Leonid.Grossman@neterion.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8666 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752021AbZDACwa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2009 22:52:30 -0400
Content-Disposition: inline
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD77051BF027@nekter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 01, 2009 at 10:38:07AM +0800, Ramkrishna Vepa wrote:
> > For the most part I think the bit you would be interested in is the
> > "sysfs" patch, http://patchwork.kernel.org/patch/8066/, which is what
> I
> > had used in the original implementation to enable the VFs.  I am going
> > to push this to a module parameter similar to your max_config_dev.
> The
> > rest of the patches handle PF to VF communications and configuration
> > which it sounds like is handled via firmware for your adapter.
> [Ram]Currently, the messaging interface is not part of this driver
> submission and each function driver is independent of the other - there
> are no dependencies between the PF and the VF driver.
> 
> > Most of the changes you would probably need to make would be in
> > vxge_probe/vxge_remove.  All you would end up needing to do is call
> > pci_enable_sriov(pdev, max_config_dev - 1) on your physical function
> > devices and then you would end up getting exactly as many VFs as you
> > need.  The call should be safe since I am assuming your VFs don't
> > implement their own SR-IOV capability structures.  The cleanup would
> be
> > pretty strait forward as well since you would just need to call
> > pci_disable_sriov in remove.
> [Ram] When the device indicates that it is SRIOV capable in the pci
> config space, why not create the VF pci config spaces as part of the
> enumeration process? This way, there would be no change required for the
> network drivers. 

Yes, and that's what the PCI subsystem does. If the vxge VF is identical
to its PF, then vxge should be able to drive both PF and VF without any
modification.

Thanks,
Yu
