From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [patch net-next 27/34] nfp: bpf: Convert ndo_setup_tc offloads
 to block callbacks
Date: Thu, 12 Oct 2017 18:08:24 -0700
Message-ID: <20171012180824.1e76eac1@cakuba.netronome.com>
References: <20171012171823.1431-1-jiri@resnulli.us>
        <20171012171823.1431-28-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f180.google.com ([209.85.216.180]:44733 "EHLO
        mail-qt0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753303AbdJMBIc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 21:08:32 -0400
Received: by mail-qt0-f180.google.com with SMTP id 8so16949999qtv.1
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 18:08:31 -0700 (PDT)
In-Reply-To: <20171012171823.1431-28-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Oct 2017 19:18:16 +0200, Jiri Pirko wrote:
> diff --git a/drivers/net/ethernet/netronome/nfp/bpf/offload.c b/drivers/net/ethernet/netronome/nfp/bpf/offload.c
> index a88bb5b..9e9af88 100644
> --- a/drivers/net/ethernet/netronome/nfp/bpf/offload.c
> +++ b/drivers/net/ethernet/netronome/nfp/bpf/offload.c
> @@ -246,6 +246,10 @@ int nfp_net_bpf_offload(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf)
>  	void *code;
>  	int err;
>  
> +	if (cls_bpf->common.protocol != htons(ETH_P_ALL) ||
> +	    cls_bpf->common.chain_index)
> +		return -EOPNOTSUPP;
> +
>  	max_instr = nn_readw(nn, NFP_NET_CFG_BPF_MAX_LEN);
>  
>  	switch (cls_bpf->command) {

It is certainly very ugly but I send a fake struct tc_cls_bpf_offload
here for XDP.  Refactoring this mess is pretty high on my priority list
but one way or the other this function will be called from XDP so TC
checks must stay in the TC handler... :(
