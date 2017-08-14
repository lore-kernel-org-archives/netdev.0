From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [net-next 08/15] i40e/i40evf: organize and re-number feature
 flags
Date: Mon, 14 Aug 2017 22:11:18 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5882A55079@ORSMSX115.amr.corp.intel.com>
References: <20170812110848.18264-1-jeffrey.t.kirsher@intel.com>
        <20170812110848.18264-10-jeffrey.t.kirsher@intel.com>
 <20170812.130405.1462747317744893185.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>
To: David Miller <davem@davemloft.net>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:3347 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752275AbdHNWLU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Aug 2017 18:11:20 -0400
In-Reply-To: <20170812.130405.1462747317744893185.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Saturday, August 12, 2017 1:04 PM
> To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>
> Cc: Keller, Jacob E <jacob.e.keller@intel.com>; netdev@vger.kernel.org;
> nhorman@redhat.com; sassmann@redhat.com; jogreene@redhat.com
> Subject: Re: [net-next 08/15] i40e/i40evf: organize and re-number feature flags
> 
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Sat, 12 Aug 2017 04:08:41 -0700
> 
> > Also ensure that the flags variable is actually a u64 to guarantee
> > 64bits of space on all architectures.
> 
> Why?  You don't need 64-bits, you only need 27.
> 
> This will be unnecessarily expensive on 32-bit platforms.
> 
> Please don't do this.

I suppose a better method would be to switch to using a declare_bitmap instead, so that it automatically sizes based on the number of flags we have. The reason we chose 64bits is because we will add flags in the future, as we originally had more than 32 flags prior to this patch until we moved some into a separate field.

But now that I think about it, using DECLARE_BITMAP makes more sense, though it's a bit more invasive of the code.

Thanks,
Jake
