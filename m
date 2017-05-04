From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH v2 net] xfrm: fix stack access out of bounds with
 CONFIG_XFRM_SUB_POLICY
Date: Thu, 4 May 2017 12:34:43 +0200
Message-ID: <20170504103443.GU2649@secunet.com>
References: <491a7eae3b945498515ecfb7a7963b19b405dd73.1493816960.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:37542 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751869AbdEDKev (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 06:34:51 -0400
Content-Disposition: inline
In-Reply-To: <491a7eae3b945498515ecfb7a7963b19b405dd73.1493816960.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 03, 2017 at 04:43:19PM +0200, Sabrina Dubroca wrote:
> When CONFIG_XFRM_SUB_POLICY=y, xfrm_dst stores a copy of the flowi for
> that dst. Unfortunately, the code that allocates and fills this copy
> doesn't care about what type of flowi (flowi, flowi4, flowi6) gets
> passed. In multiple code paths (from raw_sendmsg, from TCP when
> replying to a FIN, in vxlan, geneve, and gre), the flowi that gets
> passed to xfrm is actually an on-stack flowi4, so we end up reading
> stuff from the stack past the end of the flowi4 struct.
> 
> Since xfrm_dst->origin isn't used anywhere following commit
> ca116922afa8 ("xfrm: Eliminate "fl" and "pol" args to
> xfrm_bundle_ok()."), just get rid of it.  xfrm_dst->partner isn't used
> either, so get rid of that too.
> 
> Fixes: 9d6ec938019c ("ipv4: Use flowi4 in public route lookup interfaces.")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied to the ipsec tree, thanks Sabrina!
