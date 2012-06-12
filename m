From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCHv2 net-next] ipv4: Add interface option to enable routing
 of 127.0.0.0/8
Date: Tue, 12 Jun 2012 07:14:44 -0400
Message-ID: <20120612111444.GA15984@hmsreliant.think-freely.org>
References: <20120608101859.GH32152@canuck.infradead.org>
 <20120611.165740.419299184892679723.davem@davemloft.net>
 <20120612104401.GH28598@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43075 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751884Ab2FLLO5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 07:14:57 -0400
Content-Disposition: inline
In-Reply-To: <20120612104401.GH28598@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 12, 2012 at 06:44:01AM -0400, Thomas Graf wrote:
> Routing of 127/8 is tradtionally forbidden, we consider
> packets from that address block martian when routing and do
> not process corresponding ARP requests.
> 
> This is a sane default but renders a huge address space
> practically unuseable.
> 
> The RFC states that no address within the 127/8 block should
> ever appear on any network anywhere but it does not forbid
> the use of such addresses outside of the loopback device in
> particular. For example to address a pool of virtual guests
> behind a load balancer.
> 
> This patch adds a new interface option 'route_localnet'
> enabling routing of the 127/8 address block and processing
> of ARP requests on a specific interface.
> 
> Note that for the feature to work, the default local route
> covering 127/8 dev lo needs to be removed.
> 
> Example:
>   $ sysctl -w net.ipv4.conf.eth0.route_localnet=1
>   $ ip route del 127.0.0.0/8 dev lo table local
>   $ ip addr add 127.1.0.1/16 dev eth0
>   $ ip route flush cache
> 
> V2: Fix invalid check to auto flush cache (thanks davem)
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
Just out of curiosity, would it be more efficient to implement this by
optionally adding a prohibit route to the local table for 127.0.0.0/8 to every
interface that was brought up, based on weather or not that interfaces
route_localnet bool was true or not?  It would save the additional checks in the
routing path I think.  Not sure how much a savings that is, but I thought I
would ask.

Regards
Neil
