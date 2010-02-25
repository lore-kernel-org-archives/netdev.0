From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [ethtool PATCH] ethtool: Support n-tuple filter programming
Date: Wed, 24 Feb 2010 23:04:23 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.64.1002242258160.42728@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20100204075101.16661.95658.stgit@localhost.localdomain>
 <4B85F173.40703@garzik.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:23727 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752077Ab0BYHEo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2010 02:04:44 -0500
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

And you shall have it shortly.  My bad.

> 
> 2) you introduced a deviation from the upstream kernel ethtool.h:

I see what happened.  We moved those two entries in ethtool.h into the 
#ifdef __KERNEL__ section.  I can create a patch for the kernel ethtool.h 
to move them back to match userspace if that is what folks want.

> 
> 
> --- ethtool-copy.h      2010-02-24 22:39:21.000000000 -0500
> +++ ../net-next-2.6/include/linux/ethtool.h     2010-02-24 
> 22:14:43.000000000 -0500
> @@ -389,8 +389,6 @@
>   #define ETHTOOL_RXNTUPLE_ACTION_DROP -1
>   };
> 
> -#define ETHTOOL_MAX_NTUPLE_LIST_ENTRY 1024
> -#define ETHTOOL_MAX_NTUPLE_STRING_PER_ENTRY 14
>   struct ethtool_rx_ntuple {
>          __u32                                   cmd;
>          struct ethtool_rx_ntuple_flow_spec      fs;
> 
> 
> 
