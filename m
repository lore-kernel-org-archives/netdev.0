From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec-next v2] ipsec: add support of limited SA dump
Date: Tue, 18 Feb 2014 06:46:15 +0100
Message-ID: <20140218054615.GA32371@secunet.com>
References: <1392223581-25554-1-git-send-email-nicolas.dichtel@6wind.com>
 <1392388236-3093-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <herbert@gondor.apana.org.au>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <fengguang.wu@intel.com>,
	<kbuild-all@01.org>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:45918 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751054AbaBRFqT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Feb 2014 00:46:19 -0500
Content-Disposition: inline
In-Reply-To: <1392388236-3093-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 14, 2014 at 03:30:36PM +0100, Nicolas Dichtel wrote:
> The goal of this patch is to allow userland to dump only a part of SA by
> specifying a filter during the dump.
> The kernel is in charge to filter SA, this avoids to generate useless netlink
> traffic (it save also some cpu cycles). This is particularly useful when there
> is a big number of SA set on the system.
> 
> Note that I removed the union in struct xfrm_state_walk to fix a problem on arm.
> struct netlink_callback->args is defined as a array of 6 long and the first long
> is used in xfrm code to flag the cb as initialized. Hence, we must have:
> sizeof(struct xfrm_state_walk) <= sizeof(long) * 5.
> With the union, it was false on arm (sizeof(struct xfrm_state_walk) was
> sizeof(long) * 7), due to the padding.
> In fact, whatever the arch is, this union seems useless, there will be always
> padding after it. Removing it will not increase the size of this struct (and
> reduce it on arm).
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied to ipsec-next, thanks Nicolas!
