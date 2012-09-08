From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] xfrm: Don't pass current->pid to functions expecting a netlink portid
Date: Sat, 08 Sep 2012 00:03:19 -0700
Message-ID: <871uidj8so.fsf@xmission.com>
References: <87a9x1j9qh.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jamal Hadi Salim <hadi@cyberus.ca>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:57482 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751266Ab2IHHD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Sep 2012 03:03:28 -0400
In-Reply-To: <87a9x1j9qh.fsf@xmission.com> (Eric W. Biederman's message of
	"Fri, 07 Sep 2012 23:43:02 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ignore this patch.  The issue is real this fix is wrong.

> diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
> index 4801c81..d7bfd27 100644
> --- a/net/xfrm/xfrm_user.c
> +++ b/net/xfrm/xfrm_user.c
> @@ -1930,7 +1930,7 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
>  		// reset the timers here?
>  		WARN(1, "Dont know what to do with soft policy expire\n");
>  	}
> -	km_policy_expired(xp, p->dir, up->hard, current->pid);
> +	km_policy_expired(xp, p->dir, up->hard, 0);
>  
>  out:
>  	xfrm_pol_put(xp);
> @@ -1958,7 +1958,7 @@ static int xfrm_add_sa_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
>  	err = -EINVAL;
>  	if (x->km.state != XFRM_STATE_VALID)
>  		goto out;
> -	km_state_expired(x, ue->hard, current->pid);
> +	km_state_expired(x, ue->hard, 0);
>  
>  	if (ue->hard) {
>  		uid_t loginuid = audit_get_loginuid(current);
