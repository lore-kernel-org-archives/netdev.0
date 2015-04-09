From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v3 net-next 2/2] tc: add 'needs_l2' flag to ingress qdisc
Date: Thu, 09 Apr 2015 17:38:22 +0200
Message-ID: <55269CEE.5040406@iogearbox.net>
References: <1428535575-7736-1-git-send-email-ast@plumgrid.com>	<1428535575-7736-2-git-send-email-ast@plumgrid.com> <20150408.224404.1913719826015357860.davem@davemloft.net> <5525EC69.1080606@plumgrid.com> <5526593E.4040608@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, jiri@resnulli.us, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52301 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755487AbbDIPia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 11:38:30 -0400
In-Reply-To: <5526593E.4040608@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/09/2015 12:49 PM, Jamal Hadi Salim wrote:
...
> Your changes penalize everyone else because of this assumption
> bpf makes. We have always tried to be sensitive to perfomance.

That includes also BPF, right? ;) I mean you'd need to push extra
unneeded per-packet instructions down into the interpreter and
JITs that neither the output path needs in case of {cls,act}_bpf,
and generally other users working on skbs such as team driver, all
possible kind of sockets with filters attached, xt_bpf, etc, etc
just to accommodate for the ingress use-case. I mean I understand
your concern, but making BPF cls/act responsible for that knowledge
has it's downsides just as well.

Moreover, we'd enforce user space to start programming with
unintuitive negative offsets when accessing mac layer, and cls_bpf
at least, since it's around for some time, would need to start
differentiating between classic and native eBPF to keep compat
with old BPF programs for the output path. That's pretty messy. :/
