From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 27/34] nfp: bpf: Convert ndo_setup_tc offloads
 to block callbacks
Date: Tue, 17 Oct 2017 14:48:12 +0200
Message-ID: <20171017124812.GH2112@nanopsycho>
References: <20171012171823.1431-1-jiri@resnulli.us>
 <20171012171823.1431-28-jiri@resnulli.us>
 <20171012180824.1e76eac1@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:47115 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761883AbdJQMsO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 08:48:14 -0400
Received: by mail-wm0-f66.google.com with SMTP id t69so3664571wmt.2
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 05:48:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171012180824.1e76eac1@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Oct 13, 2017 at 03:08:24AM CEST, jakub.kicinski@netronome.com wrote:
>On Thu, 12 Oct 2017 19:18:16 +0200, Jiri Pirko wrote:
>> diff --git a/drivers/net/ethernet/netronome/nfp/bpf/offload.c b/drivers/net/ethernet/netronome/nfp/bpf/offload.c
>> index a88bb5b..9e9af88 100644
>> --- a/drivers/net/ethernet/netronome/nfp/bpf/offload.c
>> +++ b/drivers/net/ethernet/netronome/nfp/bpf/offload.c
>> @@ -246,6 +246,10 @@ int nfp_net_bpf_offload(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf)
>>  	void *code;
>>  	int err;
>>  
>> +	if (cls_bpf->common.protocol != htons(ETH_P_ALL) ||
>> +	    cls_bpf->common.chain_index)
>> +		return -EOPNOTSUPP;
>> +
>>  	max_instr = nn_readw(nn, NFP_NET_CFG_BPF_MAX_LEN);
>>  
>>  	switch (cls_bpf->command) {
>
>It is certainly very ugly but I send a fake struct tc_cls_bpf_offload
>here for XDP.  Refactoring this mess is pretty high on my priority list
>but one way or the other this function will be called from XDP so TC
>checks must stay in the TC handler... :(

Okay. But currently, why is it a problem? You don't need the checks for
xdp path.
