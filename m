From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [RFC PATCH v2 net-next 0/2] BPF and OVS extensions
Date: Tue, 17 Sep 2013 23:58:07 -0700
Message-ID: <CAMEtUuwhK1Ygi76OWZEPWEie9RXzbCmu2mJX8T4K_W8R29Wc7A@mail.gmail.com>
References: <1379386119-4157-1-git-send-email-ast@plumgrid.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B733F@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Xi Wang <xi.wang@gmail.com>,
	David Howells <dhowells@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ben Pfaff <blp@nicira.com>, Thomas Graf <tgraf@suug.ch>,
	dev@openvswitch.org
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:55782 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751652Ab3IRG6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 02:58:08 -0400
Received: by mail-we0-f172.google.com with SMTP id w61so5993630wes.17
        for <netdev@vger.kernel.org>; Tue, 17 Sep 2013 23:58:07 -0700 (PDT)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B733F@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 17, 2013 at 1:40 AM, David Laight <David.Laight@aculab.com> wrote:
>
> > Patch 1/2: generic BPF extension
> > Original A and X 32-bit BPF registers are replaced with ten 64-bit registers.
> > bpf opcode encoding kept the same. load/store were generalized to access stack,
> > bpf_tables and bpf_context.
> > BPF program interfaces to outside world via tables that it can read and write,
> > and via bpf_context which is in/out blob of data.
> > Other kernel components can provide callbacks to tailor BPF to specific needs.
>
> As has been recently pointed out on some of the NetBSD lists
> one of the points about BPF is that the filters are deterministic
> and easily proven to both terminate and have no unwanted side effects.
>
> The functionality you are proposing breaks both of these assumptions.

Proposed BPF extensions keep both of these assumptions. See bpf_check.c
It guarantees that BPF program terminates, all memory/register
accesses are valid,
function arguments are verified, no unknown insns, register/stack is initialized
before read, aligned, etc
BPF checker algorithm is not as trivial as it was before, but still
straightforward and simple.
It helped us catch some interesting bugs in BPF GCC backend. In one
case we miscalculated
branch target by one insn and since register read came before it was
written, BPF checker caught it.
In another case we improperly coded branch conditions in cbranchdi4
(see gcc/config/bpf/bpf.md on github). Again it caught it.
Using compiler is not mandatory. One can code BPF in assembler in the
same way it was done before,
but doing it in C is easier to understand.

Thanks
Alexei
