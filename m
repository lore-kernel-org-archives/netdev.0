From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] net/bridge: use the maximum hard_header_len of ports
 for bridging device
Date: Mon, 23 Mar 2009 08:51:22 -0700
Message-ID: <20090323085122.4c9d21f2@nehalam>
References: <1237539869-30721-1-git-send-email-leoli@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	Li Yang <leoli@freescale.com>
To: Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59829 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754220AbZCWPvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 11:51:35 -0400
In-Reply-To: <1237539869-30721-1-git-send-email-leoli@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Mar 2009 17:04:29 +0800
Li Yang <leoli@freescale.com> wrote:

> The bridging device used a constant hard_header_len.  This will cause
> headroom shortage for ports with additional hardware header.  The patch
> makes bridging device to use the maximum value of all ports.
> 
> Signed-off-by: Li Yang <leoli@freescale.com>
> ---

That ensures big enough header for locally generated packets, but
any drivers that need bigger headroom still must handle bridged packets
that come in with smaller space. When bridging packets, the skb comes
from the allocation by the receiving driver. Almost all drivers will
use dev_alloc_skb() which will allocate NET_SKB_PAD (16) bytes of
additional headroom. This is used to hold copy of ethernet header for
the bridge/netfilter code.

So your patch is fine as an optimization but a driver can not safely
depend on any additional headroom. The driver must check if there
is space, and if no space is available, reallocate and copy.
