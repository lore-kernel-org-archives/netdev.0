From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [patch net-next v4 1/2] tc: add BPF based action
Date: Wed, 14 Jan 2015 22:55:25 +0100
Message-ID: <54B6E5CD.2070504@redhat.com>
References: <1421257404-25452-1-git-send-email-jiri@resnulli.us> <CAHA+R7NWShJo_0apkOa5pudpE69EdWkzAQpW00zfO7ePhxt2XA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Hannes Frederic Sowa <hannes@redhat.com>, willemb@google.com
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50687 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753945AbbANVzk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2015 16:55:40 -0500
In-Reply-To: <CAHA+R7NWShJo_0apkOa5pudpE69EdWkzAQpW00zfO7ePhxt2XA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/14/2015 08:27 PM, Cong Wang wrote:
> On Wed, Jan 14, 2015 at 9:43 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> This action provides a possibility to exec custom BPF code.
>
> I still don't like it, sorry, not just for your patch, I never like
> cls_bpf either, in terms of the user interface and the duplicated
> functionalities: cls_bpf vs u32, act_bpf vs gact.
...
> Ideally we should be able to implement them with the same
> interface, transparent to users, I think probably because
> the nature of bpf implementation somewhat enforces such
> interface everywhere, it is clearly overrated.

Hmm, I guess you're talking about the interface from tc side, other
than that cls_bpf is also faster when JITed. I can only speak for
cls_bpf here, which is modelled the same way after xt_bpf and takes
low-level BPF opcodes directly or stored somewhere as a file. Not
overly pretty, that's true.

For somewhat higher but still low-level enough description, I've
added bpf_asm for that purpose so you can still have full control
and if that's still too much and you don't care about unsupported
BPF extensions, then the libpcap compiler is your friend. For example,
Willem has added [1] longer time ago which takes tcpdump-like
filters and spills out related opcodes for you, if you don't want
to use tcpdump -ddd directly.

The other possibility would be to have an own internal BPF filter
compiler inside of tc (w/o any external lib dependencies), a thought
lingering in my head for quite some time now. I guess I could scratch
some cycles off from my spare time and start hacking on it.

Other than that, for the eBPF part, there are efforts to upstream
backends to llvm and gcc, afaik, so their produced output could be
passed onwards to tc, similarly as in samples/bpf/ as one possibility
I could imagine.

   [1] http://git.netfilter.org/iptables/tree/utils/nfbpf_compile.c
