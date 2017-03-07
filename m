From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [xfrm] xfrm: Added the auth and enc update support in "state
 update"
Date: Tue, 7 Mar 2017 11:20:53 +0100
Message-ID: <20170307102053.GJ694@gauss.secunet.com>
References: <1488536619-14363-1-git-send-email-trajaraman@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: <trajaraman@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:48734 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754745AbdCGKcS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Mar 2017 05:32:18 -0500
Content-Disposition: inline
In-Reply-To: <1488536619-14363-1-git-send-email-trajaraman@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 03, 2017 at 03:53:39PM +0530, trajaraman@mvista.com wrote:
> From: Thiruvadi rajaraman <trajaraman@mvista.com>
> 
> Updated the xfrm state update process to update the
> Authendication and Encryption keys.
> 
> Signed-off-by: Thiruvadi rajaraman <trajaraman@mvista.com>
> ---
>  net/xfrm/xfrm_state.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
> index 419bf5d..6b15447 100644
> --- a/net/xfrm/xfrm_state.c
> +++ b/net/xfrm/xfrm_state.c
> @@ -1388,6 +1388,12 @@ int xfrm_state_update(struct xfrm_state *x)
>  		memcpy(&x1->lft, &x->lft, sizeof(x1->lft));
>  		x1->km.dying = 0;
>  
> +		/* To update Authendication and Encryption keys */
> +		x1->aalg = kmemdup(x->aalg, xfrm_alg_auth_len(x->aalg),
> +								GFP_KERNEL);
> +		x1->ealg = kmemdup(x->ealg, xfrm_alg_len(x->ealg),
> +								GFP_KERNEL);

Please explain why you need this and which bug it fixes.
Please write this into the commit message. The commit
message should explain why this change is needed in the
first place. Also please align you patch to common coding
style.

Thanks!
