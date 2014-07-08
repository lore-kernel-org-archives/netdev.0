From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: icmp: Fix pMTU handling for rare case
Date: Mon, 07 Jul 2014 17:23:29 -0700 (PDT)
Message-ID: <20140707.172329.1811708260574978031.davem@davemloft.net>
References: <1404141362-21015-1-git-send-email-edward.allcutt@openmarket.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: edward.allcutt@openmarket.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47819 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754253AbaGHAXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 20:23:31 -0400
In-Reply-To: <1404141362-21015-1-git-send-email-edward.allcutt@openmarket.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Allcutt <edward.allcutt@openmarket.com>
Date: Mon, 30 Jun 2014 16:16:02 +0100

> Some older router implementations still send Fragmentation Needed
> errors with the Next-Hop MTU field set to zero. This is explicitly
> described as an eventuality that hosts must deal with by the
> standard (RFC 1191) since older standards specified that those
> bits must be zero.
> 
> Linux had a generic (for all of IPv4) implementation of the algorithm
> described in the RFC for searching a list of MTU plateaus for a good
> value. Commit 46517008e116 ("ipv4: Kill ip_rt_frag_needed().")
> removed this as part of the changes to remove the routing cache.
> Subsequently any Fragmentation Needed packet with a zero Next-Hop
> MTU has been discarded without being passed to the per-protocol
> handlers or notifying userspace for raw sockets.
> 
> When there is a router which does not implement RFC 1191 on an
> MTU limited path then this results in stalled connections since
> large packets are discarded and the local protocols are not
> notified so they never attempt to lower the pMTU.
> 
> One example I have seen is an OpenBSD router terminating IPSec
> tunnels. It's worth pointing out that this case is distinct from
> the BSD 4.2 bug which incorrectly calculated the Next-Hop MTU
> since the commit in question dismissed that as a valid concern.
> 
> All of the per-protocols handlers implement the simple approach from
> RFC 1191 of immediately falling back to the minimum value. Although
> this is sub-optimal it is vastly preferable to connections hanging
> indefinitely.
> 
> Remove the Next-Hop MTU != 0 check and allow such packets
> to follow the normal path.
> 
> Fixes: 46517008e116 ("ipv4: Kill ip_rt_frag_needed().")
> Signed-off-by: Edward Allcutt <edward.allcutt@openmarket.com>

Applied and queued up for -stable, thanks.
