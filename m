From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v3 2/2] ss: support closing inet sockets via
 SOCK_DESTROY.
Date: Wed, 30 Dec 2015 12:34:14 -0800
Message-ID: <20151230123414.008f5e35@xeon-e3>
References: <20151221214222.5ee87383@xeon-e3>
	<1450773094-7978-1-git-send-email-lorenzo@google.com>
	<1450773094-7978-3-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	zenczykowski@gmail.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36802 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753338AbbL3UeG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 15:34:06 -0500
Received: by mail-pf0-f169.google.com with SMTP id 65so101597171pff.3
        for <netdev@vger.kernel.org>; Wed, 30 Dec 2015 12:34:05 -0800 (PST)
In-Reply-To: <1450773094-7978-3-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Dec 2015 17:31:34 +0900
Lorenzo Colitti <lorenzo@google.com> wrote:

>  
> +static int kill_inet_sock(const struct sockaddr_nl *addr,
> +		struct nlmsghdr *h, void *arg)
> +{
> +	struct inet_diag_msg *d = NLMSG_DATA(h);
> +	struct inet_diag_arg *diag_arg = arg;
> +	struct rtnl_handle *rth = diag_arg->rth;
> +	DIAG_REQUEST(req, struct inet_diag_req_v2 r);
> +
> +	req.nlh.nlmsg_type = SOCK_DESTROY;
> +	req.nlh.nlmsg_flags = NLM_F_REQUEST | NLM_F_ACK;
> +	req.nlh.nlmsg_seq = ++rth->seq;
> +	req.r.sdiag_family = d->idiag_family;
> +	req.r.sdiag_protocol = diag_arg->protocol;
> +	req.r.id = d->id;
> +
> +	return rtnl_send_check_ack(rth, &req.nlh, req.nlh.nlmsg_len, 1);

Just use rtnl_talk() instead, it does request/reply.
