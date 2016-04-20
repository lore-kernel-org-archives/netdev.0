From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 WIP] ifstat: use new RTM_GETSTATS api
Date: Wed, 20 Apr 2016 11:53:47 -0700
Message-ID: <20160420115347.6a43d7f7@xeon-e3>
References: <1461168975-28081-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36129 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbcDTSxg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 14:53:36 -0400
Received: by mail-pa0-f45.google.com with SMTP id er2so20386062pad.3
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 11:53:36 -0700 (PDT)
In-Reply-To: <1461168975-28081-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Apr 2016 09:16:15 -0700
Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> +int rtnl_wilddump_stats_req_filter(struct rtnl_handle *rth, int family, int type,
> +				   __u32 filt_mask)
> +{
> +	struct {
> +		struct nlmsghdr nlh;
> +		struct if_stats_msg ifsm;
> +	} req;

Please use C99 initialization instead of memset in new code.

> +	int err;
> +
> +	memset(&req, 0, sizeof(req));
> +	req.nlh.nlmsg_len = sizeof(req);
> +	req.nlh.nlmsg_type = type;
> +	req.nlh.nlmsg_flags = NLM_F_DUMP|NLM_F_REQUEST;
> +	req.nlh.nlmsg_pid = 0;
> +	req.nlh.nlmsg_seq = rth->dump = ++rth->seq;
> +	req.ifsm.family = family;
> +	req.ifsm.filter_mask = filt_mask;
> +
> +	err = send(rth->fd, (void*)&req, sizeof(req), 0);
> +
> +	return err;

Why not just:
        return send(rth->fd, &req, sizoef(req), 0);

> +}
