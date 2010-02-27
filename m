From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [net-next-2.6 PATCH] ethtool: Add n-tuple string length to
 drvinfo and return it
Date: Sat, 27 Feb 2010 12:28:27 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.64.1002271226270.61048@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20100226115355.20213.59254.stgit@localhost.localdomain>
 <4B87D31B.4000001@garzik.org> <1267228162.2224.38.camel@localhost>
 <4B88BC2C.1030304@garzik.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38700 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030784Ab0B0U3a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Feb 2010 15:29:30 -0500
In-Reply-To: <4B88BC2C.1030304@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Feb 2010, Jeff Garzik wrote:

> On 02/26/2010 06:49 PM, Peter P Waskiewicz Jr wrote:
> > On Fri, 2010-02-26 at 05:56 -0800, Jeff Garzik wrote:
> >> On 02/26/2010 06:54 AM, Jeff Kirsher wrote:
> >>> From: Peter Waskiewicz<peter.p.waskiewicz.jr@intel.com>
> >>>
> >>> The drvinfo struct should include the number of strings that
> >>> get_rx_ntuple will return.  It will be variable if an underlying
> >>> driver implements its own get_rx_ntuple routine, so userspace
> >>> needs to know how much data is coming.
> >>>
> >>> Signed-off-by: Peter P Waskiewicz Jr<peter.p.waskiewicz.jr@intel.com>
> >>> Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
> >>> ---
> >>>
> >>>    include/linux/ethtool.h |    1 +
> >>>    net/core/ethtool.c      |    3 +++
> >>>    2 files changed, 4 insertions(+), 0 deletions(-)
> >>
> >> (resending reply, standard patch-sending box is having trouble sending
> >> to vger)
> >>
> >>
> >> As noted in the other email, your patch breaks ABI.  The proper path is
> >> to decrease the size of reserved struct member, and NOT shift the offset
> >> of other members.
> >>
> >>
> >>
> >> However, perhaps consider the following patch for returning n-tuple
> >> count, for four reasons:
> >>
> >> 1) space in ethtool_drvinfo is limited
> >>
> >> 2) the patch below permits trivial string set addition, without
> >>      ABI changes beyond adding a new ETH_SS_xxx constant.
> >>
> >> 3) the patch below permits direct access to ops->get_sset_count(),
> >>      rather than implicit access via ethtool_drvinfo
> >>
> >> 4) ethtool_drvinfo interface does not permit indication of
> >>      ops->get_sset_count() failure, versus returning zero value.  The
> >>      patch below does so, via output sset_mask.
> >>
> >> WARNING: this patch is compile-tested only.
> >>
> >> NOTE: I added a cosmetic fix to ETHTOOL_[GS]RXNTUPLE constants, making
> >> their indentation consistent with the rest of the list of constants.
> >>
> >> Signed-off-by: Jeff Garzik<jgarzik@redhat.com>
> >
> > I'm updating your patch since I found an issue.  The mask is passing in
> > the ETH_SS_* flags, but then they're treated as bits, not enumerated
> > flags.  I'm thinking of the best non-intrusive way to correct it.
> 
> As Ben noted, you cannot change those enumerated values, as they are 
> already part of the ABI.

Apologies.  My outstanding IT support marked your and Ben's emails as 
spam, and moved it aside where I couldn't see them until this morning...

> 
> For ETHTOOL_GSSET_INFO, you initialize the sset_mask like this:
> 
> 	info.sset_mask = (1ULL << ETH_SS_NTUPLE_FILTERS);
> 
> A multiple initialization would look like this:
> 
> 	info.sset_mask = (1ULL << ETH_SS_NTUPLE_FILTERS) |
> 			(1ULL << ETH_SS_STATS) |
> 			(1ULL << ETH_SS_PRIV_FLAGS);
> 
> Do you still see an issue in my suggested code, now that sset_mask 
> confusion is cleared up?

This sounds like it makes sense.  I'll make the changes (and the userspace 
change you suggested in another mail) and get new patches out.

> 
> Regards,
> 
> 	Jeff
