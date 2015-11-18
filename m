From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [ss PATCH 2/2] ss: support closing inet sockets via SOCK_DIAG.
Date: Tue, 17 Nov 2015 19:12:39 -0800
Message-ID: <1447816359.22599.129.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447811530-10756-1-git-send-email-lorenzo@google.com>
	 <1447811530-10756-3-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, ek@google.com,
	maze@google.com, dtor@google.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35799 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751768AbbKRDMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 22:12:42 -0500
Received: by pacej9 with SMTP id ej9so29222828pac.2
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 19:12:42 -0800 (PST)
In-Reply-To: <1447811530-10756-3-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-11-18 at 10:52 +0900, Lorenzo Colitti wrote:
>  
> +static int kill_inet_sock(const struct sockaddr_nl *addr,
> +		struct nlmsghdr *h, void *arg)
> +{
> +	struct rtnl_handle rth;
> +	if (rtnl_open_byproto(&rth, 0, NETLINK_SOCK_DIAG))
> +		return -1;
> +
> +	struct inet_diag_arg *diag_arg = arg;
> +	struct inet_diag_msg *d = NLMSG_DATA(h);
> +	DIAG_REQUEST(req, struct inet_diag_req_v2 r);
> +	req.nlh.nlmsg_type = SOCK_DESTROY;
> +	req.nlh.nlmsg_flags = NLM_F_REQUEST | NLM_F_ACK;
> +	req.r.sdiag_family = d->idiag_family;
> +	req.r.sdiag_protocol = diag_arg->protocol;
> +	req.r.id = d->id;
> +
> +	int err = rtnl_talk(&rth, &req.nlh, NULL, 0);
> +	rtnl_close(&rth);
> +	return err;
> +}


1) Please do not mix variables and code.

2) opening/closing a control socket for every killed TCP socket is going
to consume a lot of cpu cycles.

 
