From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] etherdevice: introduce broadcast_ether_addr
Date: Tue, 03 Jul 2012 08:13:22 -0700
Message-ID: <1341328402.2164.3.camel@joe2Laptop>
References: <1341310587.5131.2.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:48188 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751081Ab2GCPNX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jul 2012 11:13:23 -0400
In-Reply-To: <1341310587.5131.2.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-03 at 12:16 +0200, Johannes Berg wrote:
> From: Johannes Berg <johannes.berg@intel.com>
> 
> A lot of code has either the memset or an
> inefficient copy from a static array that
> contains the all-ones broadcast address.
> Introduce broadcast_ether_addr() to fill
> an address with all ones, making the code
> clearer and allowing us to get rid of the
> various constant arrays.
[]
> diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
[]
> +static inline void broadcast_ether_addr(u8 *addr)
> +{
> +	memset(addr, 0xff, ETH_ALEN);
> +}

I think this sort of patch should come as the first
patch in a series with some example conversions.

It might be too easy to confuse is_broadcast_ether_addr
with this function name too.  Maybe set_broadcast_ether_addr
might be better.

I really don't see an issue with using memset though.
Everyone already knows what that does.
