From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] xen-netback: remove unconditional
 __pskb_pull_tail() in guest Tx path
Date: Thu, 06 Nov 2014 14:40:57 -0500 (EST)
Message-ID: <20141106.144057.541605315482589279.davem@davemloft.net>
References: <1415184622-19421-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	ian.campbell@citrix.com, wei.liu2@citrix.com,
	malcolm.crossley@citrix.com
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57953 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbaKFTk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 14:40:59 -0500
In-Reply-To: <1415184622-19421-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Wed, 5 Nov 2014 10:50:22 +0000

> From: Malcolm Crossley <malcolm.crossley@citrix.com>
> 
> Unconditionally pulling 128 bytes into the linear area is not required
> for:
> 
> - security: Every protocol demux starts with pskb_may_pull() to pull
>   frag data into the linear area, if necessary, before looking at
>   headers.
> 
> - performance: Netback has already grant copied up-to 128 bytes from
>   the first slot of a packet into the linear area. The first slot
>   normally contain all the IPv4/IPv6 and TCP/UDP headers.
> 
> The unconditional pull would often copy frag data unnecessarily.  This
> is a performance problem when running on a version of Xen where grant
> unmap avoids TLB flushes for pages which are not accessed.  TLB
> flushes can now be avoided for > 99% of unmaps (it was 0% before).
> 
> Grant unmap TLB flush avoidance will be available in a future version
> of Xen (probably 4.6).
> 
> Signed-off-by: Malcolm Crossley <malcolm.crossley@citrix.com>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Applied, thanks.
