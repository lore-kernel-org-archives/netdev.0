From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 4/5] MIPS: Add support for eBPF JIT.
Date: Wed, 14 Jun 2017 02:04:51 +0200
Message-ID: <59407DA3.8050206@iogearbox.net>
References: <20170613222847.7122-1-david.daney@cavium.com> <20170613222847.7122-5-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Markos Chandras <markos.chandras@imgtec.com>,
        Matt Redfearn <matt.redfearn@imgtec.com>
To: David Daney <david.daney@cavium.com>,
        Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        ralf@linux-mips.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170613222847.7122-5-david.daney@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/14/2017 12:28 AM, David Daney wrote:
> Since the eBPF machine has 64-bit registers, we only support this in
> 64-bit kernels.  As of the writing of this commit log test-bpf is showing:
>
>    test_bpf: Summary: 316 PASSED, 0 FAILED, [308/308 JIT'ed]
>
> All current test cases are successfully compiled.
>
> Many examples in samples/bpf are usable, specifically tracex5 which
> uses tail calls works.
>
> Signed-off-by: David Daney <david.daney@cavium.com>

Awesome work, David! The bits interacting with core BPF look
good to me.

Fyi, when Ralf merges this and it goes later on to Linus, there
will be two minor (silent) merge conflicts with net-next tree
(depending which one gets there first):

1) In bpf_int_jit_compile(), below the jited = 1 assignment, there
    needs to come a prog->jited_len = image_size.

2) The internal tail call opcode changed from BPF_JMP | BPF_CALL | BPF_X
    into BPF_JMP | BPF_TAIL_CALL.

Cheers,
Daniel
