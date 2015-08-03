From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] act_bpf: properly support late binding of bpf
 action to a classifier
Date: Mon, 03 Aug 2015 16:06:19 -0700 (PDT)
Message-ID: <20150803.160619.1456376856814017427.davem@davemloft.net>
References: <8e2446e087041587d665a8ca2d105f164a8e0794.1438610179.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, jiri@resnulli.us, jhs@mojatatu.com,
	netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45475 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751640AbbHCXGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 19:06:20 -0400
In-Reply-To: <8e2446e087041587d665a8ca2d105f164a8e0794.1438610179.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon,  3 Aug 2015 16:21:57 +0200

> Since the introduction of the BPF action in d23b8ad8ab23 ("tc: add BPF
> based action"), late binding was not working as expected. I.e. setting
> the action part for a classifier only via 'bpf index <num>', where <num>
> is the index of an existing action, is being rejected by the kernel due
> to other missing parameters.
> 
> It doesn't make sense to require these parameters such as BPF opcodes
> etc, as they are not going to be used anyway: in this case, they're just
> allocated/parsed and then freed again w/o doing anything meaningful.
> 
> Instead, parse and verify the remaining parameters *after* the test on
> tcf_hash_check(), when we really know that we're dealing with creation
> of a new action or replacement of an existing one and where late binding
> is thus irrelevant.
> 
> After patch, test case is now working:
> 
>   FOO="1,6 0 0 4294967295,"
>   tc actions add action bpf bytecode "$FOO"
>   tc filter add dev foo parent 1: bpf bytecode "$FOO" flowid 1:1 action bpf index 1
>   tc actions show action bpf
>     action order 0: bpf bytecode '1,6 0 0 4294967295' default-action pipe
>     index 1 ref 2 bind 1
>   tc filter show dev foo
>     filter protocol all pref 49152 bpf
>     filter protocol all pref 49152 bpf handle 0x1 flowid 1:1 bytecode '1,6 0 0 4294967295'
>     action order 1: bpf bytecode '1,6 0 0 4294967295' default-action pipe
>     index 1 ref 2 bind 1
> 
> Late binding of a BPF action can be useful for preloading maps (e.g. before
> they hit traffic) in case of eBPF programs, or to share a single eBPF action
> with multiple classifiers.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied to net-next, thanks Daniel.
