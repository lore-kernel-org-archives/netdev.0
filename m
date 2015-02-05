From: Thomas Graf <tgraf@noironetworks.com>
Subject: Re: [ovs-dev] [RFC: add openvswitch actions using BPF 2/9] odp: add
 a new ODP action: OVS_ACTION_ATTR_BPF_PROG
Date: Thu, 5 Feb 2015 14:56:16 +0100
Message-ID: <20150205135616.GB5546@pox.localdomain>
References: <1423090163-19902-1-git-send-email-azhou@nicira.com>
 <1423090163-19902-3-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.com, netdev@vger.kernel.org
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:55651 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753137AbbBEN4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 08:56:19 -0500
Received: by mail-wi0-f182.google.com with SMTP id n3so10682570wiv.3
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 05:56:18 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1423090163-19902-3-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/04/15 at 02:49pm, Andy Zhou wrote:
>  /**
> + * struct ovs_action_bpf_prog - %OVS_ACTION_ATTR_BPF_PROG action argument.
> + *
> + *  XXX provides bpf program id and execution context.
> + *
> + */
> +struct ovs_action_bpf_prog {
> +	__be32 prog_fd;
> +	__be32 arg0;
> +	__be32 arg1;
> +};

I assume you intend to replace this with a nested Netlink attribute with a
series of U32 attributes to carry args in the future?

> +enum ovs_bpf_func_id {
> +	OVS_BPF_FUNC_unspec,
> +	OVS_BPF_FUNC_output,          /* int ovs_bpf_output(ctxt) */
> +	__OVS_BPF_FUNC_MAX_ID,
> +};

The mix of cap / no-cap looks a bit weird.

> +static void
> +format_bpf_prog_action(struct ds *ds, const struct nlattr *a)
> +{
> +    struct ovs_action_bpf_prog *bpf_act = (struct ovs_action_bpf_prog *)
> +                                          nl_attr_get(a);
> +
> +    ds_put_cstr(ds, "bpf");
> +    ds_put_format(ds, "(%u,%u,%u)", ntohl(bpf_act->prog_fd),
> +                  ntohl(bpf_act->arg0), ntohl(bpf_act->arg1));
> +}

Maybe ds_put_format(ds, "bpf(... ?
