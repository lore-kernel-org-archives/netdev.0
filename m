From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH ipsec v3] xfrm: prevent ipcomp scratch buffer race
 condition
Date: Thu, 17 Oct 2013 06:38:37 -0700
Message-ID: <1382017117.2045.146.camel@edumazet-glaptop.roam.corp.google.com>
References: <20131017095502.GD7660@secunet.com>
	 <20131017130740.D8741E8A5E@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:42609 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755514Ab3JQNik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 09:38:40 -0400
Received: by mail-pb0-f48.google.com with SMTP id ma3so2314477pbc.21
        for <netdev@vger.kernel.org>; Thu, 17 Oct 2013 06:38:39 -0700 (PDT)
In-Reply-To: <20131017130740.D8741E8A5E@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-17 at 15:07 +0200, Michal Kubecek wrote:
> In ipcomp_compress(), sortirq is enabled too early, allowing the
> per-cpu scratch buffer to be rewritten by ipcomp_decompress()
> (called on the same CPU in softirq context) between populating
> the buffer and copying the compressed data to the skb.
> 
> v2: as pointed out by Steffen Klassert, if we also move the
> local_bh_disable() before reading the per-cpu pointers, we can
> get rid of get_cpu()/put_cpu().
> 
> v3: removed ipcomp_decompress part (as explained by Herbert Xu,
> it cannot be called from process context), get rid of cpu
> variable (thanks to Eric Dumazet)
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> ---

Reviewed-by: Eric Dumazet <edumazet@google.com>
