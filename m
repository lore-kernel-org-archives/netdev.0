From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2] tc: add BPF based action
Date: Tue, 13 Jan 2015 14:36:33 -0500 (EST)
Message-ID: <20150113.143633.1852338751965729543.davem@davemloft.net>
References: <1421078978-10904-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, dborkman@redhat.com,
	ast@plumgrid.com, hannes@redhat.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35379 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049AbbAMTgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 14:36:36 -0500
In-Reply-To: <1421078978-10904-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 12 Jan 2015 17:09:38 +0100

> +	bpf_len = nla_get_u16(tb[TCA_ACT_BPF_OPS_LEN]);
> +	if (bpf_len > BPF_MAXINSNS || bpf_len == 0)
> +		return -EINVAL;
> +
> +	bpf_size = bpf_len * sizeof(*bpf_ops);

When I see variables named 'len' and 'size', I expect them to be
in unit bytes.

I think it's clearer to call bpf_len something like "bpf_num_insns",
or "bpf_num_ops", or something like that.

Also, is the OPS_LEN attribute really necessary?  Can't you just
figure this out using nla_len() on the OPS attribute?  Or is that not
always accurate due to alignment?
