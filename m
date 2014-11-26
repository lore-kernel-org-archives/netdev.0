From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 0/5 net] bridge: Fix missing Netlink message validations
Date: Wed, 26 Nov 2014 17:06:10 +0000
Message-ID: <20141126170610.GA2399@casper.infradead.org>
References: <cover.1417005245.git.tgraf@suug.ch>
 <547606B3.3060808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, davem@davemloft.net,
	stephen@networkplumber.org, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:33802 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752628AbaKZRGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 12:06:12 -0500
Content-Disposition: inline
In-Reply-To: <547606B3.3060808@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/14 at 08:58am, John Fastabend wrote:
> On 11/26/2014 04:42 AM, Thomas Graf wrote:
> >Adds various missing length checks in the bridging code for Netlink
> >messages and corresponding attributes provided by user space.
> >
> >Thomas Graf (5):
> >   bridge: Validate IFLA_BRIDGE_FLAGS attribute length
> >   net: Validate IFLA_BRIDGE_MODE attribute length
> >   net: Check for presence of IFLA_AF_SPEC
> >   bridge: Add missing policy entry for IFLA_BRPORT_FAST_LEAVE
> >   bridge: Sanitize IFLA_EXT_MASK for AF_BRIDGE:RTM_GETLINK
> >
> >  drivers/net/ethernet/emulex/benet/be_main.c   |  5 +++++
> >  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  5 +++++
> >  net/bridge/br_netlink.c                       |  1 +
> >  net/core/rtnetlink.c                          | 23 ++++++++++++++++++-----
> >  4 files changed, 29 insertions(+), 5 deletions(-)
> >
> 
> +Jiri
> 
> Looks like a miss in bond_netlink also? Seems like writing
> a smatch or cocci check for this would be worthwhile.

Thanks, I'll take a look.

The cocci check is somewhat difficult as validation is often
centralized and decoupled from actual access to implement atomic
operations. I'll give it a try though.
