From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPSEC][4/7] inter address family ipsec tunnel
Date: Wed, 06 Dec 2006 23:37:49 -0800 (PST)
Message-ID: <20061206.233749.122048397.davem@davemloft.net>
References: <20061130.164827.57154936.davem@davemloft.net>
	<456FB283.9090904@miyazawa.org>
	<20061206203537.2e5ba9ec.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: miika@iki.fi, Diego.Beltrami@hiit.fi, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44398
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1031803AbWLGHhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 02:37:37 -0500
To: kazunori@miyazawa.org
In-Reply-To: <20061206203537.2e5ba9ec.kazunori@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Date: Wed, 6 Dec 2006 20:35:37 +0900

> Sorry, I mixed up changes in the patches. I described that [4/7] will add
> "IPv6 over IPv4 IPsec tunnel". However I send a patch for "IPv4 over IPv6"
> as a reply because it includes the discussing item.
> So this patch adds IPv4 over IPv6 IPsec tunnel. It's complicated.
> 
> I deleted subustituting NULL for rt->peer and moved atomic_inc stuff
> under the "if" section.

I have applied this patch, thanks for fixing it up.

> BTW, I have a question about descrementing the reference count of
> rt->peer.  The reference cound in normal "dst" structure is
> decremented by calling inet_putpeer from ipv4_dst_destroy. But
> xfrm4_dst_destroy does not call inet_putpeer.  Where do we decrement
> the count? Should xfrm4_dst_destroy do that?

Indeed, it is a real leak.  And yes, I believe that xfrm4_dst_destroy()
should release it.  I will make this fix, thank you.
