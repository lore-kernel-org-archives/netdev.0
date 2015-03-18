From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] act_bpf: allow non-default TC_ACT opcodes as BPF
 exec outcome
Date: Tue, 17 Mar 2015 22:15:42 -0400 (EDT)
Message-ID: <20150317.221542.2280059970610472155.davem@davemloft.net>
References: <98364de656ad8034f008999121f57940af767b93.1426619298.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, ast@plumgrid.com,
	jhs@mojatatu.com
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55541 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752963AbbCRCPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 22:15:44 -0400
In-Reply-To: <98364de656ad8034f008999121f57940af767b93.1426619298.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Tue, 17 Mar 2015 20:25:57 +0100

> Revisiting commit d23b8ad8ab23 ("tc: add BPF based action") with regards
> to eBPF support, I was thinking that it might be better to improve
> return semantics from a BPF program invoked through BPF_PROG_RUN().
> 
> Currently, in case filter_res is 0, we overwrite the default action
> opcode with TC_ACT_SHOT. A default action opcode configured through tc's
> m_bpf can be: TC_ACT_RECLASSIFY, TC_ACT_PIPE, TC_ACT_SHOT, TC_ACT_UNSPEC,
> TC_ACT_OK.
> 
> In cls_bpf, we have the possibility to overwrite the default class
> associated with the classifier in case filter_res is _not_ 0xffffffff
> (-1).
> 
> That allows us to fold multiple [e]BPF programs into a single one, where
> they would otherwise need to be defined as a separate classifier with
> its own classid, needlessly redoing parsing work, etc.
> 
> Similarly, we could do better in act_bpf: Since above TC_ACT* opcodes
> are exported to UAPI anyway, we reuse them for return-code-to-tc-opcode
> mapping, where we would allow above possibilities. Thus, like in cls_bpf,
> a filter_res of 0xffffffff (-1) means that the configured _default_ action
> is used. Any unkown return code from the BPF program would fail in
> tcf_bpf() with TC_ACT_UNSPEC.
> 
> Should we one day want to make use of TC_ACT_STOLEN or TC_ACT_QUEUED,
> which both have the same semantics, we have the option to either use
> that as a default action (filter_res of 0xffffffff) or non-default BPF
> return code.
> 
> All that will allow us to transparently use tcf_bpf() for both BPF
> flavours.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks Daniel.
