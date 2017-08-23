From: Wei Wang <weiwan@google.com>
Subject: Re: [PATCH net] net: xfrm: don't double-hold dst when sk_policy in use.
Date: Wed, 23 Aug 2017 10:00:50 -0700
Message-ID: <CAEA6p_CKLyxcxiMsU_E6sf7hShnv7PNm8UshJY5iTMmZY8y-7A@mail.gmail.com>
References: <20170823081439.52796-1-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        steffen.klassert@secunet.com, misterikkit@gocogle.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f179.google.com ([209.85.217.179]:38425 "EHLO
        mail-ua0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932329AbdHWRAv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 13:00:51 -0400
Received: by mail-ua0-f179.google.com with SMTP id n29so2493237uai.5
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 10:00:51 -0700 (PDT)
In-Reply-To: <20170823081439.52796-1-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

Thanks for the fix.

Acked-by: Wei Wang <weiwan@google.com>


On Wed, Aug 23, 2017 at 1:14 AM, Lorenzo Colitti <lorenzo@google.com> wrote:
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
> ---
>  net/xfrm/xfrm_policy.c | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index 6f5a0dad50..69b16ee327 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -2226,7 +2226,6 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
>                                 goto no_transform;
>                         }
>
> -                       dst_hold(&xdst->u.dst);
>                         route = xdst->route;
>                 }
>         }
> --
> 2.14.1.480.gb18f417b89-goog
>
