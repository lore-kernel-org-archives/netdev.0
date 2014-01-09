From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next 3/3] xfrm: Don't prohibit AH from using ESN
 feature
Date: Thu, 9 Jan 2014 11:50:21 +0100
Message-ID: <20140109105021.GY31491@secunet.com>
References: <1389171192-28091-1-git-send-email-fan.du@windriver.com>
 <1389171192-28091-4-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44818 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751690AbaAIKuZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 05:50:25 -0500
Content-Disposition: inline
In-Reply-To: <1389171192-28091-4-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 08, 2014 at 04:53:12PM +0800, Fan Du wrote:
> Clear checking when user try to use ESN through netlink keymgr for AH.
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>
> ---
>  net/xfrm/xfrm_user.c |    4 ----
>  1 file changed, 4 deletions(-)
> 
> diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
> index 97681a3..f362a78 100644
> --- a/net/xfrm/xfrm_user.c
> +++ b/net/xfrm/xfrm_user.c
> @@ -141,10 +141,6 @@ static inline int verify_replay(struct xfrm_usersa_info *p,
>  
>  	if (!rt)
>  		return 0;
> -
> -	if (p->id.proto != IPPROTO_ESP)
> -		return -EINVAL;
> -

You can not change this as long as AH for ipv6 does not
support ESN. Please provide the ipv6 side too.

Also, simply removing this check is wrong in any case.
You have to make sure that we catch if someone tries
to insert an ESN state for other unsupported protocols,
like ipcomp.
