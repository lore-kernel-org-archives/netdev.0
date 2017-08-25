From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net] net: xfrm: don't double-hold dst when sk_policy in
 use.
Date: Fri, 25 Aug 2017 07:16:55 +0200
Message-ID: <20170825051655.GU31224@secunet.com>
References: <20170823081439.52796-1-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <weiwan@google.com>,
        <davem@davemloft.net>, <misterikkit@gocogle.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:45958 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751411AbdHYFQ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Aug 2017 01:16:58 -0400
Content-Disposition: inline
In-Reply-To: <20170823081439.52796-1-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 23, 2017 at 05:14:39PM +0900, Lorenzo Colitti wrote:
> While removing dst_entry garbage collection, commit 52df157f17e5
> ("xfrm: take refcnt of dst when creating struct xfrm_dst bundle")
> changed xfrm_resolve_and_create_bundle so it returns an xdst with
> a refcount of 1 instead of 0.
> 
> However, it did not delete the dst_hold performed by xfrm_lookup
> when a per-socket policy is in use. This means that when a
> socket policy is in use, dst entries returned by xfrm_lookup have
> a refcount of 2, and are not freed when no longer in use.
> 
> Cc: Wei Wang <weiwan@google.com>
> Fixes: 52df157f17 ("xfrm: take refcnt of dst when creating struct xfrm_dst bundle")
> Tested: https://android-review.googlesource.com/417481
> Tested: https://android-review.googlesource.com/418659
> Tested: https://android-review.googlesource.com/424463
> Tested: https://android-review.googlesource.com/452776 passes on net-next
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

Patch applied, thanks a lot!
