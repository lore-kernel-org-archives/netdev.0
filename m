From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 net] bpf: x86: fix epilogue generation for eBPF programs
Date: Wed, 3 Dec 2014 07:51:25 -0800
Message-ID: <CAMEtUuwKk4zg6=RbORfQoAzU9C5dkv1ufhabMhfwSdRX+iB3tg@mail.gmail.com>
References: <1417301173-23691-1-git-send-email-ast@plumgrid.com>
	<CABg9mcso+YeS-sgAQmAu6MvsfNnzrKYuUG8m+WYJmxdaxbGmPA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Z Lim <zlim.lnx@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CABg9mcso+YeS-sgAQmAu6MvsfNnzrKYuUG8m+WYJmxdaxbGmPA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 2, 2014 at 10:38 PM, Z Lim <zlim.lnx@gmail.com> wrote:
> Hi Alexei,
>
> On Sat, Nov 29, 2014 at 2:46 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>> classic BPF has a restriction that last insn is always BPF_RET.
>> eBPF doesn't have BPF_RET instruction and this restriction.
>> It has BPF_EXIT insn which can appear anywhere in the program
>> one or more times and it doesn't have to be last insn.
>
> Just to confirm, in valid eBPF, BPF_EXIT *must* be present at least
> once, correct?
> Does an eBPF JIT implementation need to check for it?

yes. of course. At least one bpf_exit is always there
and there are no loops. verifier is checking for it.
So no need for jit to check it again.

> I'll cook up a patch for arm64 if you haven't already done so.
> Any related test case I should run through?

Pending socket samples are generating such code by llvm.
I was planning to add an explicit test to test_bpf, but feel free
to beat me to it.
