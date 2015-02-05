From: Thomas Graf <tgraf@noironetworks.com>
Subject: Re: [ovs-dev] [RFC: add openvswitch actions using BPF 1/2] BPF: add
 a new BPF program type BPF_PROG_TYPE_OPENVSWITCH
Date: Thu, 5 Feb 2015 15:48:28 +0100
Message-ID: <20150205144828.GF5546@pox.localdomain>
References: <1423090122-19807-1-git-send-email-azhou@nicira.com>
 <1423090122-19807-2-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.com, netdev@vger.kernel.org
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f180.google.com ([74.125.82.180]:37421 "EHLO
	mail-we0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757281AbbBEOsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 09:48:32 -0500
Received: by mail-we0-f180.google.com with SMTP id m14so8067883wev.11
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 06:48:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1423090122-19807-2-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/04/15 at 02:48pm, Andy Zhou wrote:
>  struct bpf_verifier_ops {
>  	/* return eBPF function prototype for verification */
> -	const struct bpf_func_proto *(*get_func_proto)(enum bpf_func_id func_id);
> +	const struct bpf_func_proto *(*get_func_proto)(int func_id);

This change should maybe go in a separate commit.

> +static const struct bpf_func_proto *ovs_func_proto(int func_id)
> +{
> +	switch (func_id) {
> +	case OVS_BPF_FUNC_output:
> +		return &bpf_helper_output_proto;
> +	default:
> +		return NULL;
> +	}
> +}

You'd still want to use the map helpers so it seems like we should
change the bpf verified to verify against both a global and type
specific list unless we want to add all the map helpers to
ovs_func_proto as well.

> +static bool test_is_valid_access(int off, int size, enum bpf_access_type type)
> +{
> +	const struct bpf_context_access *access;
> +
> +	if (off < 0 || off >= ARRAY_SIZE(bpf_ctx_access))
> +		return false;
> +
> +	access = &bpf_ctx_access[off];
> +	if (access->size == size && (access->type & type))
> +		return true;
> +
> +	return false;
> +}

OK. I see why you kept ctxt simple at first ;-)
