From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: export xfrm garbage collector thresholds via
 sysctl
Date: Mon, 27 Jul 2009 11:37:55 -0700 (PDT)
Message-ID: <20090727.113755.260927092.davem@davemloft.net>
References: <20090727182246.GC15823@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@nall.com, herbert@gondor.apana.org.au,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44738
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753653AbZG0Shs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 14:37:48 -0400
In-Reply-To: <20090727182246.GC15823@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 27 Jul 2009 14:22:46 -0400

> Export garbage collector thresholds for xfrm[4|6]_dst_ops
> 
> Had a problem reported to me recently in which a high volume of ipsec
> connections on a system began reporting ENOBUFS for new connections eventually.
> It seemed that after about 2000 connections we started being unable to create
> more.  A quick look revealed that the xfrm code used a dst_ops structure that
> limited the gc_thresh value to 1024, and alaways dropped route cache entries
> after 2x the gc_thresh.  It seems the most direct solution is to export the
> gc_thresh values in the xfrm[4|6] dst_ops as sysctls, like the main routing
> table does, so that higher volumes of connections can be supported.  This patch
> has been tested and allows the reporter to increase their ipsec connection
> volume successfully.
> 
> Reported-by: Joe Nall <joe@nall.com>
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied, but this suggests that either:

1) we pick a horrible default

2) our IPSEC machinery holds onto dst entries too tightly and that's
   the true cause of this problem

I'd like to ask that you investigate this, because with defaults
we should be able to handle IPSEC loads as high as the routing
loads we could handle.

Thanks.
