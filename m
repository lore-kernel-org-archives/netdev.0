From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tun: fix BUG with large packets without TUN_VNET_HDR
Date: Fri, 17 Apr 2009 07:50:23 +0800
Message-ID: <20090416235023.GC29988@gondor.apana.org.au>
References: <20090416204556.GA5846@dhcp-1-124.tlv.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Max Krasnyansky <maxk@qualcomm.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: "Michael S. Tsirkin" <m.s.tsirkin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40466 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758142AbZDPXug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 19:50:36 -0400
Content-Disposition: inline
In-Reply-To: <20090416204556.GA5846@dhcp-1-124.tlv.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 16, 2009 at 11:45:57PM +0300, Michael S. Tsirkin wrote:
> On a tap device, the linear part of skb must be at least ETH_HLEN,
> otherwise eth_type_trans triggers BUG_ON in skb_pull(skb, ETH_HLEN).
> This patch makes sure the linear part is always large enough.
> 
> Without the patch, tun sets the linear part size to 0 if TUN_VNET_HDR
> is not set and the packet is too large to put in a linear skb,
> which causes BUGs for me.
> 
> BTW, it seems that this behaviour has been there for a long while, since at
> least v2.6.27 (commit f42157cb568c1eb02eca7df4da67553a9edae24a: tun: fallback
> if skb_alloc() fails on big packets), but started triggering for me only in
> v2.6.30-rc1, because of commit 33dccbb050bbe35b88ca8cf1228dcf3e4d4b3554 (tun:
> Limit amount of queued packets per device), which made all large packets
> non-linear.  Before that, most packets would still typically be linear until
> memory gets fragmented, which hides the issue.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

I'd already fixed that a couple of days ago :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
