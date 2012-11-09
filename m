From: "Li, Sibai" <sibai.li@intel.com>
Subject: RE: SR-IOV problem with Intel 82599EB (not enough MMIO resources
 for SR-IOV)
Date: Fri, 9 Nov 2012 18:08:00 +0000
Message-ID: <A3A921390EAE4044940E99EBF13D97321AE2114C@FMSMSX104.amr.corp.intel.com>
References: <201211081915083774239@gmail.com>	<509B962C.6070002@gmail.com>
	<C5551D9AAB213A418B7FD5E4A6F30A072D565E76@ORSMSX106.amr.corp.intel.com>
 <CANmqhJDJXcbUxyt6YD6ktxZCDJ=VqiwhGXP+fLMukQr0o-XwxQ@mail.gmail.com>
 <C5551D9AAB213A418B7FD5E4A6F30A072D5683CF@ORSMSX106.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, kvm <kvm@vger.kernel.org>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	Jason Gao <pkill.2012@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:37613 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751454Ab2KISIH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 13:08:07 -0500
In-Reply-To: <C5551D9AAB213A418B7FD5E4A6F30A072D5683CF@ORSMSX106.amr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jason,

DellR710 with the latest BIOS should work fine for SR-IOV. My BIOS is v.6.3.0 and release date is 07/24/2012
Please check if you configured intel_iommu=on in the grub.conf file. 
If you did, check your kernel .config file under Device Drivers-> IOMMU Hardware support->enable Support for Intel IOMMU using DMA remapping Devices, enable Intel DMA Remapping Devices by Default, enable Support for Interrupt Remapping.

Thanks,
Sibai

> -----Original Message-----
> From: Rose, Gregory V
> Sent: Friday, November 09, 2012 9:16 AM
> To: Jason Gao; Li, Sibai
> Cc: Kirsher, Jeffrey T; linux-kernel; netdev; kvm
> Subject: RE: SR-IOV problem with Intel 82599EB (not enough MMIO resources
> for SR-IOV)
> 
> > -----Original Message-----
> > From: Jason Gao [mailto:pkill.2012@gmail.com]
> > Sent: Thursday, November 08, 2012 8:00 PM
> > To: Rose, Gregory V
> > Cc: Kirsher, Jeffrey T; linux-kernel; netdev; kvm; e1000-
> > devel@lists.sourceforge.net
> > Subject: Re: SR-IOV problem with Intel 82599EB (not enough MMIO
> > resources for SR-IOV)
> >
> > > The BIOS in your machine doesn't support SR-IOV.  You'll need to ask
> > > the
> > manufacturer for a BIOS upgrade, if in fact one is available.
> > Sometimes they're not.
> >
> > very thanks Greg,my server Dell R710 with latest BIOS version and
> > option for SR-IOV(SR-IOV Global Enable->Enabled)  opened,I'm confused
> > that Does
> > R710 provide full support for SR-IOV, kernel or  ixgbe driver's bug?
> > but I'm not sure where the problem lies,anyone has any
> > experience about this?   .
> 
> I use a Dell R710 for all my SR-IOV testing and it works fine but I had to acquire a
> special BIOS from Dell to get it to work.  As I said, you'll want to contact them
> and make sure you've got the correct BIOS.
> 
> The error you're seeing, "not enough MMIO resources" has been an issue with
> the BIOS 100% of the times that we've run into it.  In any case, it is NOT a driver
> bug.  The driver has nothing to do with allocation of MMIO space reservation for
> VF devices.  The message you're seeing pops up when the driver calls
> pci_enable_sriov().  There is nothing the driver can do to force that call to be
> successful.
> 
> I've added Sibai Li to this response.  She should be able to get the BIOS version
> string off of one of our working Dell R710s.
> 
> Sibai,
> 
> Could you please reply to this message with that information?
> 
> Thanks,
> 
> - Greg
