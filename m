From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH v3 net-next] bpf/verifier: track liveness for pruning
Date: Mon, 21 Aug 2017 21:24:24 +0100
Message-ID: <e4075575-b12c-5c6f-bac3-0c7ba8e04802@solarflare.com>
References: <f40d3d54-c88a-7348-99ca-66db8075a8d5@solarflare.com>
 <89ff34f7-84ee-0e0a-3766-5b4d046189bf@fb.com>
 <b8a46388-74ea-81f9-df08-3b6b88042229@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>
To: Alexei Starovoitov <ast@fb.com>, <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b8a46388-74ea-81f9-df08-3b6b88042229@solarflare.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18/08/17 15:16, Edward Cree wrote:
> On 18/08/17 04:21, Alexei Starovoitov wrote:
>> It seems you're trying to sort-of do per-fake-basic block liveness
>> analysis, but our state_list_marks are not correct if we go with
>> canonical basic block definition, since we mark the jump insn and
>> not insn after the branch and not every basic block boundary is
>> properly detected.
> I think the reason this works is that jump insns can't do writes.
> [snip]
> the sl->state will never have any write marks and it'll all just work.
> But I should really test that!
I tested this, and found that, no, sl->state can have write marks, and the
 algorithm will get the wrong answer in that case.  So I've got a patch to
 make the first iteration ignore write marks, as part of a series which I
 will post shortly.  When I do so, please re-do your tests with adding
 state_list_marks in strange and exciting places; it should work wherever
 you put them.  Like you say, it "magically doesn't depend on proper basic
 block boundaries", and that's because really pruning is just a kind of
 checkpointing that just happens to be most effective when done just after
 a jump (pop_stack).

Can I have a SOB for your "grr" test program, so I can include it in the
 series?

-Ed
