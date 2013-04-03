From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 5/5] IPoIB: add support for TIPC protocol
Date: Wed, 3 Apr 2013 17:44:55 +0200
Message-ID: <20130403154455.GM21481@macbook.localnet>
References: <1364993010-15515-1-git-send-email-kaber@trash.net>
 <1364993010-15515-6-git-send-email-kaber@trash.net>
 <515C4B65.4040600@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jon.maloy@ericsson.com, allan.stephens@windriver.com,
	netdev@vger.kernel.org, roland@kernel.org, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, linux-rdma@vger.kernel.org
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49530 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758556Ab3DCPpC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 11:45:02 -0400
Content-Disposition: inline
In-Reply-To: <515C4B65.4040600@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 03, 2013 at 06:31:49PM +0300, Or Gerlitz wrote:
> On 03/04/2013 15:43, Patrick McHardy wrote:
> >[...] all TIPC needs to know about is ARP and RARP since
> >it wants to always perform "path find", even if a path is already known. [...]
> 
> Not sure to follow this part... did you mean "all IPoIB  needs to
> know about is ARP or RARP", this makes
> sense indeed, since for arp/rarp we want to call unicast_arp_send
> which does path_find and looks
> also for the case the path isn't valid

What I meant is that it doesn't require any knowledge about IPv4/IPv6 or
other higher layer protocols anymore. At least almost none.

We have protocol knowledge in ipoib_start_xmit(). For broadcast packets,
it drops unknown protocols. For unicast packets, it handles ARP/RARP
seperately because of the path find differences, IP/IPv6 are sent
using the neigh, all others are dropped.

ipoib_cm also has knowledge about IPv4/IPv6 in order to send ICMP errors.

What we could do instead of adding TIPC to the broadcast-don't-drop list
and to the send-using-neigh list in ipoib_start_xmit() is to only treat
ARP/RARP special and send every other protocol using the neigh or
ipoib_mcast_send().

Right now the supported protocols are artificially limited without a
technical reason.
