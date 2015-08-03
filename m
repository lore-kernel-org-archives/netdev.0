From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] act_bpf: properly support late binding of bpf
 action to a classifier
Date: Mon, 3 Aug 2015 09:36:04 -0700
Message-ID: <55BF9874.4040504@plumgrid.com>
References: <8e2446e087041587d665a8ca2d105f164a8e0794.1438610179.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, jhs@mojatatu.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36824 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752231AbbHCQgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 12:36:06 -0400
Received: by pacgq8 with SMTP id gq8so28580059pac.3
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 09:36:05 -0700 (PDT)
In-Reply-To: <8e2446e087041587d665a8ca2d105f164a8e0794.1438610179.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/3/15 7:21 AM, Daniel Borkmann wrote:
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
> Instead, parse and verify the remaining parameters*after*  the test on
> tcf_hash_check(), when we really know that we're dealing with creation
> of a new action or replacement of an existing one and where late binding
> is thus irrelevant.
>
> After patch, test case is now working:
>
>    FOO="1,6 0 0 4294967295,"
>    tc actions add action bpf bytecode "$FOO"
>    tc filter add dev foo parent 1: bpf bytecode "$FOO" flowid 1:1 action bpf index 1
>    tc actions show action bpf
>      action order 0: bpf bytecode '1,6 0 0 4294967295' default-action pipe
>      index 1 ref 2 bind 1
>    tc filter show dev foo
>      filter protocol all pref 49152 bpf
>      filter protocol all pref 49152 bpf handle 0x1 flowid 1:1 bytecode '1,6 0 0 4294967295'
>      action order 1: bpf bytecode '1,6 0 0 4294967295' default-action pipe
>      index 1 ref 2 bind 1
>
> Late binding of a BPF action can be useful for preloading maps (e.g. before
> they hit traffic) in case of eBPF programs, or to share a single eBPF action
> with multiple classifiers.
>
> Signed-off-by: Daniel Borkmann<daniel@iogearbox.net>
> ---
>   This one was still in my queue of fixes, net-next is totally fine here.
>   Will push out minor iproute2 change afterwards.

All makes sense.
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
