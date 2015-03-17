From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] act_bpf: allow non-default TC_ACT opcodes as BPF
 exec outcome
Date: Tue, 17 Mar 2015 23:27:53 +0100
Message-ID: <20150317222753.GA2169@nanopsycho.orion>
References: <98364de656ad8034f008999121f57940af767b93.1426619298.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:34107 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932366AbbCQW15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 18:27:57 -0400
Received: by wibg7 with SMTP id g7so54138931wib.1
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 15:27:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <98364de656ad8034f008999121f57940af767b93.1426619298.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Mar 17, 2015 at 08:25:57PM CET, daniel@iogearbox.net wrote:
>Revisiting commit d23b8ad8ab23 ("tc: add BPF based action") with regards
>to eBPF support, I was thinking that it might be better to improve
>return semantics from a BPF program invoked through BPF_PROG_RUN().
>
>Currently, in case filter_res is 0, we overwrite the default action
>opcode with TC_ACT_SHOT. A default action opcode configured through tc's
>m_bpf can be: TC_ACT_RECLASSIFY, TC_ACT_PIPE, TC_ACT_SHOT, TC_ACT_UNSPEC,
>TC_ACT_OK.
>
>In cls_bpf, we have the possibility to overwrite the default class
>associated with the classifier in case filter_res is _not_ 0xffffffff
>(-1).
>
>That allows us to fold multiple [e]BPF programs into a single one, where
>they would otherwise need to be defined as a separate classifier with
>its own classid, needlessly redoing parsing work, etc.
>
>Similarly, we could do better in act_bpf: Since above TC_ACT* opcodes
>are exported to UAPI anyway, we reuse them for return-code-to-tc-opcode
>mapping, where we would allow above possibilities. Thus, like in cls_bpf,
>a filter_res of 0xffffffff (-1) means that the configured _default_ action
>is used. Any unkown return code from the BPF program would fail in
>tcf_bpf() with TC_ACT_UNSPEC.
>
>Should we one day want to make use of TC_ACT_STOLEN or TC_ACT_QUEUED,
>which both have the same semantics, we have the option to either use
>that as a default action (filter_res of 0xffffffff) or non-default BPF
>return code.
>
>All that will allow us to transparently use tcf_bpf() for both BPF
>flavours.
>
>Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>Cc: Jiri Pirko <jiri@resnulli.us>
>Cc: Alexei Starovoitov <ast@plumgrid.com>
>Cc: Jamal Hadi Salim <jhs@mojatatu.com>
>---
> Note, act_bpf has not been officially released with 4.0, so we can
> still address it.

Thanks for taking care of this Daniel

Acked-by: Jiri Pirko <jiri@resnulli.us>
