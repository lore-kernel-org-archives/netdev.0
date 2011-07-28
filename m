From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC net-next PATCH 2/4] ixgbe: Reconfigure SR-IOV Init
Date: Thu, 28 Jul 2011 08:44:36 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755019414D4FC@orsmsx508.amr.corp.intel.com>
References: <20110727221406.8435.44324.stgit@gitlad.jf.intel.com>
	<20110727221754.8435.99712.stgit@gitlad.jf.intel.com>
 <20110727.222653.1937782529626247279.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:41029 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754976Ab1G1Poi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 11:44:38 -0400
In-Reply-To: <20110727.222653.1937782529626247279.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, July 27, 2011 10:27 PM
> To: Rose, Gregory V
> Cc: netdev@vger.kernel.org; bhutchings@solarflare.com; Kirsher, Jeffrey T
> Subject: Re: [RFC net-next PATCH 2/4] ixgbe: Reconfigure SR-IOV Init
> 
> From: Greg Rose <gregory.v.rose@intel.com>
> Date: Wed, 27 Jul 2011 15:17:54 -0700
> 
> > +	int i;
> > +	for (i = 0; i < adapter->num_vfs; i++) {
> > +		if (adapter->vfinfo[i].vfdev->dev_flags &
> > +			PCI_DEV_FLAGS_ASSIGNED) {
> > +		return true;
> > +		}
> > +	}
> 
> Bad formatting and indentation, please fix this.

Will do.

> 
> > +		pvfdev = pci_get_device(IXGBE_INTEL_VENDOR_ID, device_id,
> NULL);
> > +		while (pvfdev) {
> > +			if (pvfdev->devfn == thisvf_devfn)
> > +				break;
> > +			pvfdev = pci_get_device(IXGBE_INTEL_VENDOR_ID,
> > +						device_id, pvfdev);
> > +		}
> > +		if (pvfdev)
> > +			adapter->vfinfo[vfn].vfdev = pvfdev;
> 
> pci_get_*() grabs a reference to any non-NULL pci device object
> returned, where does this reference get released?  I scanned
> all uses of x.vfdev and x->vfdev and could not find the necessary
> release.

I was ignorant of this behavior.  I'll fix it.

- Greg

