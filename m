From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 2/2] SELinux: indicate fatal error in compat netfilter
 code
Date: Tue, 23 Nov 2010 11:32:08 -0500
Message-ID: <1290529928.5359.19.camel@sifl>
References: <20101123162802.3588.74894.stgit@paris.rdu.redhat.com>
	 <20101123162808.3588.18495.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@tycho.nsa.gov,
	davem@davemloft.net
To: Eric Paris <eparis@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:34771 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754049Ab0KWQcM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Nov 2010 11:32:12 -0500
In-Reply-To: <20101123162808.3588.18495.stgit@paris.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-11-23 at 11:28 -0500, Eric Paris wrote:
> The SELinux ip postroute code indicates when policy rejected a packet and
> passes the error back up the stack.  The compat code does not.  This patch
> sends the same kind of error back up the stack in the compat code.
> 
> Based-on-patch-by: Paul Moore <paul.moore@hp.com>
> Signed-off-by: Eric Paris <eparis@redhat.com>

Reviewed-by: Paul Moore <paul.moore@hp.com>

> ---
> 
>  security/selinux/hooks.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index bd6dc16..dd1690f 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -4529,11 +4529,11 @@ static unsigned int selinux_ip_postroute_compat(struct sk_buff *skb,
>  	if (selinux_secmark_enabled())
>  		if (avc_has_perm(sksec->sid, skb->secmark,
>  				 SECCLASS_PACKET, PACKET__SEND, &ad))
> -			return NF_DROP;
> +			return NF_DROP_ERR(-ECONNREFUSED);
>  
>  	if (selinux_policycap_netpeer)
>  		if (selinux_xfrm_postroute_last(sksec->sid, skb, &ad, proto))
> -			return NF_DROP;
> +			return NF_DROP_ERR(-ECONNREFUSED);
>  
>  	return NF_ACCEPT;
>  }
> 

-- 
paul moore
linux @ hp


