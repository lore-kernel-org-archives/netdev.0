From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 net-next 0/2] split BPF out of core networking
Date: Tue, 3 Jun 2014 13:58:21 -0700
Message-ID: <CAMEtUuzsHJioXZtuGje6UmwZmcmDZEn8PdkkYanA9j1sp242+Q@mail.gmail.com>
References: <1401692506-7796-1-git-send-email-ast@plumgrid.com>
	<538C3C94.3080206@redhat.com>
	<CAMEtUuzkjZCsReWH9cZs8AU0mJjZH9YOdCBTWusxe6-NZ9mQ=g@mail.gmail.com>
	<538CAEA6.4060307@redhat.com>
	<CAMEtUuwxJOgYgFjg9deQZOffeg6-JUGZXZ1Rj344eQmriQ0F0Q@mail.gmail.com>
	<538D8DAA.7090105@redhat.com>
	<CAMEtUuw8uyCGeLeUB0PXm5cCpqcsjPLZt6y9FcKjapbVPjWTuw@mail.gmail.com>
	<538E319B.3000606@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:54054 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933624AbaFCU6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 16:58:22 -0400
Received: by mail-wg0-f52.google.com with SMTP id l18so7308659wgh.23
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2014 13:58:21 -0700 (PDT)
In-Reply-To: <538E319B.3000606@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 3, 2014 at 1:35 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 06/03/2014 05:44 PM, Alexei Starovoitov wrote:
> ...
>>
>> All of your points are valid. They are right questions to ask. I just
>>
>> don't see why you're still arguing about first step of filter.c split,
>> whereas your concerns are about steps 2, 3, 4.
>
>
> Fair enough, lets keep them in mind though for future work. Btw,

Ok :)

> are other files planned for kernel/bpf/ or should it instead just
> simply be kernel/bpf.c?

The most obvious one is eBPF verifier in separate file (kernel/bpf/verifier.c)
bpf maps is yet another thing, but that's different topic.
Probably a set of bpf-callable functions in another file. Like right now
for sockets these helpers are __skb_get_pay_offset(), __skb_get_nlattr()
For tracing there will be a different set of helper functions and eventually
some will be common. Like __get_raw_cpu_id() from filter.c could
eventually move to kernel/bpf/helpers.c
I'm not a fan of squeezing different logic into one file.
