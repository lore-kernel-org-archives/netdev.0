From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: (Lack of) specification for RX n-tuple filtering
Date: Thu, 22 Jul 2010 14:50:18 -0700
Message-ID: <4C48BD1A.4060409@chelsio.com>
References: <1279832544.2104.63.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:16855 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752223Ab0GVVu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 17:50:28 -0400
In-Reply-To: <1279832544.2104.63.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> The n-tuple filtering facility is half-baked at present.  There is an
> interface to add filters but none to remove them!  And ETHTOOL_GRXNTUPLE
> is not at all symmetric with ETHTOOL_SRXNTUPLE (which I complained about
> at the time it was added, to no avail).

It's a bit worse than that.  Currently one can only append filters, not 
insert at a given position, as ethtool_rx_ntuple doesn't have an index 
field.  For devices that use TCAMs, where position matters, it's quite an 
obstacle.  It also means one cannot modify an existing filter by specifying 
a new filter for the same index.


> 
> An ETHTOOL_RESET command with flag ETH_RESET_FILTER set could be defined
> to clear all the filters, but that's a big hammer to use, and I think
> that in general drivers should push the same configuration back to the
> hardware after resetting it for whatever reason.
> 
> So far as I can work out, ixgbe clears all the filters when the filter
> table fills up.  Is that true?  Is this really the intended behaviour of
> manually set filters?
> 
> I also see this in the ixgbe implementation:
> 
> 	/*
> 	 * Program the relevant mask registers.  If src/dst_port or src/dst_addr
> 	 * are zero, then assume a full mask for that field.  Also assume that
> 	 * a VLAN of 0 is unspecified, so mask that out as well.  L4type
> 	 * cannot be masked out in this implementation.
> 	 *
> 	 * This also assumes IPv4 only.  IPv6 masking isn't supported at this
> 	 * point in time.
> 	 */
> 
> An IPv4 address of 0 is certainly valid, so this isn't a good rule.  And
> in any case, such a rule should be specified *with the interface*, in
> <linux/ethtool.h>, not the implementation.
> 
> This also implies that 'mask' specifies bits to be ignored, not bits to
> be matched.  That also was not specified.
> 
> Ben.`
> 

