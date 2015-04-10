From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v3 net-next 2/2] tc: add 'needs_l2' flag to ingress qdisc
Date: Fri, 10 Apr 2015 07:49:45 -0400
Message-ID: <5527B8D9.6030606@mojatatu.com>
References: <1428535575-7736-1-git-send-email-ast@plumgrid.com>	<1428535575-7736-2-git-send-email-ast@plumgrid.com> <20150408.224404.1913719826015357860.davem@davemloft.net> <5525EC69.1080606@plumgrid.com> <5526593E.4040608@mojatatu.com> <55269CEE.5040406@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, jiri@resnulli.us, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:36159 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754894AbbDJMMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 08:12:12 -0400
Received: by iebrs15 with SMTP id rs15so14958264ieb.3
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 05:12:12 -0700 (PDT)
In-Reply-To: <55269CEE.5040406@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/09/15 11:38, Daniel Borkmann wrote:
> On 04/09/2015 12:49 PM, Jamal Hadi Salim wrote:
> ...
>> Your changes penalize everyone else because of this assumption
>> bpf makes. We have always tried to be sensitive to perfomance.
>
> That includes also BPF, right? ;)

Yes, of course - we are trying to reach some conclusion i hope. I
have no qualms on ebpf;  but I have concerns for other users of tc.
If the whole world is suddenly going to shift to ebpf then it is
easy to make a call. I doubt that will _ever_ happen.
As a new kid on the block ebpf needs to provide a strong case for
making such changes which affect everyone else.
It is not a simple "fix" that Alexei posted that will suffice to
make everything on ingress appear at offset 0. I am afraid, a lot
more intrusion will be needed (and we have avoided it all these
years).

> I mean you'd need to push extra
> unneeded per-packet instructions down into the interpreter and
> JITs that neither the output path needs in case of {cls,act}_bpf,
> and generally other users working on skbs such as team driver, all
> possible kind of sockets with filters attached, xt_bpf, etc, etc
> just to accommodate for the ingress use-case. I mean I understand
> your concern, but making BPF cls/act responsible for that knowledge
> has it's downsides just as well.
>

The main downside is usability for someone who wants to write code
that is inserted in the kernel. They have to know whether their code
will run on ingress or egress and the type of device etc.
The AT_XXX provides that signal and dev->type fills in the other gap.
Such coders i hope will have enough knowledge. It is close to
someone writing netfilter hooks needing to know that something is
at post/pre-routing etc

> Moreover, we'd enforce user space to start programming with
> unintuitive negative offsets when accessing mac layer, and cls_bpf
> at least, since it's around for some time, would need to start
> differentiating between classic and native eBPF to keep compat
> with old BPF programs for the output path. That's pretty messy. :/


I agree that user facing usability issues need to be addressed but that
is not the same as someone writing ebpf code.
The  negative offset presentation to the user does look ugly. You can
teach tc for the case of u32 to hide that from the user.

cheers,
jamal
