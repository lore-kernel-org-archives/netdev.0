From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next] xfrm: Namespacify xfrm_policy_sk_bundles
Date: Mon, 16 Dec 2013 13:23:25 +0100
Message-ID: <20131216122325.GI31491@secunet.com>
References: <1387189568-31769-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:56314 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753963Ab3LPMXh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 07:23:37 -0500
Content-Disposition: inline
In-Reply-To: <1387189568-31769-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 16, 2013 at 06:26:08PM +0800, Fan Du wrote:
> 
> And also since xfrm_policy_sk_bundles is only used in xfrm_lookup and
> __xfrm_garbage_collect, both in process context, no reason we should turn
> BH off.

Are you sure about that?

__xfrm_garbage_collect() is called via dst_alloc() which can be called
from softirq and process context.


> In addition we can use xchg to avoid the spinlock, inspired by
> discussion in: http://marc.info/?l=linux-netdev&m=138713363113003&w=2
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>
> ---
> Please note this patch is based on commit 283bc9f35bbbcb0e9ab4e6d2427da7f9f710d52d
> ("xfrm: Namespacify xfrm state/policy locks"), which is still in ipsec-next tree.
>
 
You could use

Subject: [PATCH ipsec-next] xfrm: Namespacify xfrm_policy_sk_bundles

then everybody should know on which tree it is based.
