From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 07/29] x86: bpf_jit, use ENTRY+ENDPROC
Date: Mon, 24 Apr 2017 14:24:20 -0400 (EDT)
Message-ID: <20170424.142420.290668473718207530.davem@davemloft.net>
References: <71301a81-1c61-fd4d-5b1b-5154fa723859@suse.cz>
        <20170424164717.GA80404@ast-mbp.thefacebook.com>
        <26f5afd7-d70b-effa-e528-8d0a2b95717a@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, mingo@kernel.org, mingo@redhat.com,
        tglx@linutronix.de, hpa@zytor.com, x86@kernel.org,
        jpoimboe@redhat.com, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, daniel@iogearbox.net, edumazet@google.com
To: jslaby@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <26f5afd7-d70b-effa-e528-8d0a2b95717a@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Slaby <jslaby@suse.cz>
Date: Mon, 24 Apr 2017 19:51:54 +0200

> For example what's the point of making the sk_load_word_positive_offset
> label a global, callable function? Note that this is exactly the reason
> why this particular two hunks look weird to you even though the
> annotations only mechanically paraphrase what is in the current code.

So that it can be referenced by the eBPF JIT, because these are
helpers for eBPF JIT generated code.  Every architecture implementing
an eBPF JIT has this "mess".

You can't even put a tracepoint or kprobe on these things and expect
to see "arguments" or "return PC" values in the usual spots.  This
code has special calling conventions and register usage as Alexei
explained.

I would suggest that you read and understand how this assembler is
designed, how it is called from the generated JIT code, and what it's
semantics and register usage are, before trying to annotating it.

Thank you.
