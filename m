From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [net-next-2.6 PATCH] ethtool: Add n-tuple string length to
 drvinfo and return it
Date: Fri, 26 Feb 2010 15:49:22 -0800
Message-ID: <1267228162.2224.38.camel@localhost>
References: <20100226115355.20213.59254.stgit@localhost.localdomain>
	 <4B87D31B.4000001@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:39909 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966562Ab0BZXtZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2010 18:49:25 -0500
In-Reply-To: <4B87D31B.4000001@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-02-26 at 05:56 -0800, Jeff Garzik wrote:
> On 02/26/2010 06:54 AM, Jeff Kirsher wrote:
> > From: Peter Waskiewicz<peter.p.waskiewicz.jr@intel.com>
> >
> > The drvinfo struct should include the number of strings that
> > get_rx_ntuple will return.  It will be variable if an underlying
> > driver implements its own get_rx_ntuple routine, so userspace
> > needs to know how much data is coming.
> >
> > Signed-off-by: Peter P Waskiewicz Jr<peter.p.waskiewicz.jr@intel.com>
> > Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
> > ---
> >
> >   include/linux/ethtool.h |    1 +
> >   net/core/ethtool.c      |    3 +++
> >   2 files changed, 4 insertions(+), 0 deletions(-)
> 
> (resending reply, standard patch-sending box is having trouble sending 
> to vger)
> 
> 
> As noted in the other email, your patch breaks ABI.  The proper path is
> to decrease the size of reserved struct member, and NOT shift the offset
> of other members.
> 
> 
> 
> However, perhaps consider the following patch for returning n-tuple
> count, for four reasons:
> 
> 1) space in ethtool_drvinfo is limited
> 
> 2) the patch below permits trivial string set addition, without
>     ABI changes beyond adding a new ETH_SS_xxx constant.
> 
> 3) the patch below permits direct access to ops->get_sset_count(),
>     rather than implicit access via ethtool_drvinfo
> 
> 4) ethtool_drvinfo interface does not permit indication of
>     ops->get_sset_count() failure, versus returning zero value.  The
>     patch below does so, via output sset_mask.
> 
> WARNING: this patch is compile-tested only.
> 
> NOTE: I added a cosmetic fix to ETHTOOL_[GS]RXNTUPLE constants, making
> their indentation consistent with the rest of the list of constants.
> 
> Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

I'm updating your patch since I found an issue.  The mask is passing in
the ETH_SS_* flags, but then they're treated as bits, not enumerated
flags.  I'm thinking of the best non-intrusive way to correct it.

-PJ

