From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next v3 2/2] ipv6: remove from fib tree aged out
 RTF_CACHE dst
Date: Thu, 19 Oct 2017 14:02:21 -0700
Message-ID: <20171019210221.kucy67evij65nctx@kafai-mbp.dhcp.thefacebook.com>
References: <cover.1508421311.git.pabeni@redhat.com>
 <6440bf87fe967880ff90c1eb732081769f81f4a0.1508421311.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
        Wei Wang <weiwan@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:54174 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753283AbdJSVCb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 17:02:31 -0400
Content-Disposition: inline
In-Reply-To: <6440bf87fe967880ff90c1eb732081769f81f4a0.1508421311.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 19, 2017 at 02:07:11PM +0000, Paolo Abeni wrote:
> The commit 2b760fcf5cfb ("ipv6: hook up exception table to store
> dst cache") partially reverted the commit 1e2ea8ad37be ("ipv6: set
> dst.obsolete when a cached route has expired").
> 
> As a result, RTF_CACHE dst referenced outside the fib tree will
> not be removed until the next sernum change; dst_check() does not
> fail on aged-out dst, and dst->__refcnt can't decrease: the aged
> out dst will stay valid for a potentially unlimited time after the
> timeout expiration.
> 
> This change explicitly removes RTF_CACHE dst from the fib tree when
> aged out. The rt6_remove_exception() logic will then obsolete the
> dst and other entities will drop the related reference on next
> dst_check().
> 
> pMTU exceptions are not aged-out, and are removed from the exception
> table only when the - usually considerably longer - ip6_rt_mtu_expires
> timeout expires.
> 
> v1 -> v2:
>   - do not touch dst.obsolete in rt6_remove_exception(), not needed
> v2 -> v3:
>   - take care of pMTU exceptions, too
> 
> Fixes: 2b760fcf5cfb ("ipv6: hook up exception table to store dst cache")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
Acked-by: Martin KaFai Lau <kafai@fb.com>
