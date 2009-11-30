From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC PATCH 1/4] net: Add support to netdev ops for changing
 hardware queue MAC and VLAN filters
Date: Mon, 30 Nov 2009 17:03:23 +1100
Message-ID: <20091130060323.GA17989@verge.net.au>
References: <1258573987.2780.20.camel@achroite.uk.solarflarecom.com>
 <EA929A9653AAE14F841771FB1DE5A1365FA69A3162@rrsmsx501.amr.corp.intel.com>
 <1258586065.2780.31.camel@achroite.uk.solarflarecom.com>
 <EA929A9653AAE14F841771FB1DE5A1365FA69A337F@rrsmsx501.amr.corp.intel.com>
 <1258642493.2837.8.camel@achroite.uk.solarflarecom.com>
 <EA929A9653AAE14F841771FB1DE5A1365FA6A1FF82@rrsmsx501.amr.corp.intel.com>
 <1258657155.2837.10.camel@achroite.uk.solarflarecom.com>
 <EA929A9653AAE14F841771FB1DE5A1365FA6A200AD@rrsmsx501.amr.corp.intel.com>
 <1258982570.2845.8.camel@achroite.uk.solarflarecom.com>
 <EA929A9653AAE14F841771FB1DE5A1365FA6A9617F@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: "Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:48393 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347AbZK3GDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 01:03:18 -0500
Content-Disposition: inline
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FA6A9617F@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 23, 2009 at 12:52:48PM -0700, Williams, Mitch A wrote:
> >From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> >Sent: Monday, November 23, 2009 5:23 AM
> [snip]
> 
> >
> >How does this interact with use of multiple queues within a single
> >function?  Are the specified queue numbers really interpreted as RX
> >queue indices or as function numbers?
> >
> >Ben.
> 
> Yeah, that is ambiguous.  Would it be better if we changed the name of the parameter to 'vf' instead of 'queue' to make it explicit?
> 
> This would give us:
> $ ip link set eth1 vf 1 mac <blah>
> 
> The issue of which VF goes with which PF device can be deduced in
> userspace via sysfs.

Does this mean that the configuration of filtering for a VF needs
to be done where the interface for the VF exists - e.g. in a KVM
guest/Xen domU?

In terms of dealing with interfaces and the way that tools such as ip work
that makes a lot of sense. But I wonder if it actually makes more sense
from an administrative point of view to have this configuration go through
the PF - e.g. the KVM host/Xen domO.

