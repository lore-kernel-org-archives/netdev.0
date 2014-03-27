From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2 net] vlan: Mask off vlan acceleration features on vlan
 device.
Date: Thu, 27 Mar 2014 08:14:26 +0000
Message-ID: <20140327081425.GA2479@macbook.localnet>
References: <1395865521-2318-1-git-send-email-vyasevic@redhat.com>
 <1395865711-3347-1-git-send-email-vyasevic@redhat.com>
 <20140326.171038.2150319831233512825.davem@davemloft.net>
 <20140326211504.GA21393@macbook.localnet>
 <53337678.9050208@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42178 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753781AbaC0IOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 04:14:31 -0400
Content-Disposition: inline
In-Reply-To: <53337678.9050208@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 26, 2014 at 08:53:12PM -0400, Vlad Yasevich wrote:
> On 03/26/2014 05:15 PM, Patrick McHardy wrote:
> > On Wed, Mar 26, 2014 at 05:10:38PM -0400, David Miller wrote:
> >> From: Vlad Yasevich <vyasevic@redhat.com>
> >> Date: Wed, 26 Mar 2014 16:28:31 -0400
> >>
> >>> Some drivers incorrectly assign vlan acceleration features to
> >>> vlan_features thus causing issues for Q-in-Q vlan configurations.
> >>> Prevent this once and for all by masking off acceleration features
> >>> for vlan devices until such time as we support stacked acceleration.
> >>>
> >>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> >>
> >> So what if we do have chips that can offload Q-in-Q?  Will we use
> >> a new flag?
> > 
> > For 802.1ad that was the intention, using the NETIF_F_HW_VLAN_STAG_* flags.
> > 
> 
> But we can't really do that as we don't carry multiple vlan_tci in the
> skb.  If the card advertises VLAN_STAG_*, then we'll offload that, but
> CTAG will have to be computed by software.  More infrastructure is
> needed to support nested vlan offloads.

True, we'd need more room in the skb to store both tags for Q-in-Q.
