From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec v3] xfrm: prevent ipcomp scratch buffer race
 condition
Date: Fri, 18 Oct 2013 11:25:12 +0200
Message-ID: <20131018092512.GA31491@secunet.com>
References: <20131017095502.GD7660@secunet.com>
 <20131017130740.D8741E8A5E@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:52832 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751961Ab3JRJZP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Oct 2013 05:25:15 -0400
Content-Disposition: inline
In-Reply-To: <20131017130740.D8741E8A5E@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 17, 2013 at 03:07:40PM +0200, Michal Kubecek wrote:
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

Applied to the ipsec tree, thanks everyone!
