From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] sparc64: eBPF JIT
Date: Tue, 18 Apr 2017 14:37:32 -0400 (EDT)
Message-ID: <20170418.143732.1494140903085244508.davem@davemloft.net>
References: <20170417232740.GB96258@ast-mbp.thefacebook.com>
        <20170417.181245.1402412750148031248.davem@davemloft.net>
        <20170418054444.GA36377@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sparclinux@vger.kernel.org, netdev@vger.kernel.org, ast@kernel.org,
        daniel@iogearbox.net
To: alexei.starovoitov@gmail.com
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20170418054444.GA36377@ast-mbp.thefacebook.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Mon, 17 Apr 2017 22:44:47 -0700

> The way llvm generates stack access is:
> rX = r10
> rX += imm
> and that's the only thing verifier recognizes as valid ptr_to_stack.
> Like rX -= imm will not be recognized as proper stack offset,
> since llvm never does it.

That simplifies things significantly for me.

I only allow moves from the frame pointer to another register,
and when I see that I rewrite it to "add FP, STACK_BIAS, DST_REG"
