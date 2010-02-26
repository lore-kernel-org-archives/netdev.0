From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [ethtool PATCH] ethtool: Support n-tuple filter programming
Date: Thu, 25 Feb 2010 17:49:39 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.64.1002251739130.51452@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20100204075101.16661.95658.stgit@localhost.localdomain>
 <4B85F173.40703@garzik.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: Jeff Garzik <jeff@garzik.org>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:59604 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934883Ab0BZBtr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2010 20:49:47 -0500
In-Reply-To: <4B85F173.40703@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 Feb 2010, Jeff Garzik wrote:

> On 02/04/2010 02:51 AM, Jeff Kirsher wrote:
> > From: Peter Waskiewicz<peter.p.waskiewicz.jr@intel.com>
> >
> > Program underlying ethernet devices with n-tuple flow classification
> > filters.
> >
> > This also adds a new flag to ethtool_flags, allowing n-tuple
> > programming to be toggled using the set_flags call.
> >
> > Signed-off-by: Peter P Waskiewicz Jr<peter.p.waskiewicz.jr@intel.com>
> > Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
> > ---
> >
> >   ethtool-copy.h |   35 +++++++++++++
> >   ethtool.c      |  156 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
> >   2 files changed, 186 insertions(+), 5 deletions(-)
> 
> applied, but two problems remain:
> 
> 1) you failed to document this in the man page.  I will expect a patch 
> to ethtool.8.
> 
> 2) you introduced a deviation from the upstream kernel ethtool.h:

The way I've come up with to fix this is less intrusive than I want, but I 
think it's right way to do it.  The intent wasn't to have ethtool 
(userspace) enforce how many filters could be returned.  What it should do 
is get the number of strings through drvinfo to make the proper memory 
allocation.

What I need to change is the drvinfo struct in the kernel to include the 
ethtool strings field, returned from get_sset_count().  Then I can pull 
that into userspace and make the correct memory allocation, then call 
get_rx_ntuple().

This will require a small kernel change.  Will something like this be 
pulled in at this point, given that 2.6.33 just released?

-PJ
