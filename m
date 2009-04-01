From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [ANNOUNCE] New driver vxge for Neterion's X3100 series 10 GbEPCIe adapter
Date: Tue, 31 Mar 2009 22:38:07 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77051BF027@nekter>
References: <1237018825.4966.412.camel@flash> <20090331061333.GA11240@yzhao-otc.sh.intel.com> <78C9135A3D2ECE4B8162EBDCE82CAD77051BEEA1@nekter> <49D257D0.9050104@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Zhao, Yu" <yu.zhao@intel.com>, "Netdev" <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
To: "Alexander Duyck" <alexander.h.duyck@intel.com>,
	"Leonid Grossman" <Leonid.Grossman@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:14748 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753498AbZDACiK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 22:38:10 -0400
Content-class: urn:content-classes:message
In-Reply-To: <49D257D0.9050104@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> For the most part I think the bit you would be interested in is the
> "sysfs" patch, http://patchwork.kernel.org/patch/8066/, which is what
I
> had used in the original implementation to enable the VFs.  I am going
> to push this to a module parameter similar to your max_config_dev.
The
> rest of the patches handle PF to VF communications and configuration
> which it sounds like is handled via firmware for your adapter.
[Ram]Currently, the messaging interface is not part of this driver
submission and each function driver is independent of the other - there
are no dependencies between the PF and the VF driver.

> Most of the changes you would probably need to make would be in
> vxge_probe/vxge_remove.  All you would end up needing to do is call
> pci_enable_sriov(pdev, max_config_dev - 1) on your physical function
> devices and then you would end up getting exactly as many VFs as you
> need.  The call should be safe since I am assuming your VFs don't
> implement their own SR-IOV capability structures.  The cleanup would
be
> pretty strait forward as well since you would just need to call
> pci_disable_sriov in remove.
[Ram] When the device indicates that it is SRIOV capable in the pci
config space, why not create the VF pci config spaces as part of the
enumeration process? This way, there would be no change required for the
network drivers. 

Ram
