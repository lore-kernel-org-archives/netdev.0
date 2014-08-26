From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 net-next 1/6] net: filter: add "load 64-bit
 immediate" eBPF instruction
Date: Mon, 25 Aug 2014 18:06:21 -0700 (PDT)
Message-ID: <20140825.180621.1003932711320755950.davem@davemloft.net>
References: <1409014858-1410-1-git-send-email-ast@plumgrid.com>
	<1409014858-1410-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@kernel.org, torvalds@linux-foundation.org,
	luto@amacapital.net, rostedt@goodmis.org, dborkman@redhat.com,
	chema@google.com, edumazet@google.com, a.p.zijlstra@chello.nl,
	brendan.d.gregg@gmail.com, namhyung@kernel.org, hpa@zytor.com,
	akpm@linux-foundation.org, keescook@chromium.org,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ast@plumgrid.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1409014858-1410-2-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Mon, 25 Aug 2014 18:00:53 -0700

> add BPF_LD_IMM64 instruction to load 64-bit immediate value into a register.

I think you need to rethink this.

I understand that you want to be able to compile arbitrary C code into
eBPF, but you have to restrict strongly what data the eBPF code can get
to.

Arbitrary pointer loads is asking for trouble.

Instead I would rather you look into a model like what the quake
engine uses for it's VM.

Namely, the program can do loads and stores from/to a data section,
but all of them are validated to be in the range of the VM program's
image.

eBPF programs should only be able to access things using either:

1) Well defined entry/exit points for control transfer

2) Load/Store within a private limited data segment range used
   only by the eBPF program

I don't want the eBPF program to be able to get "out of it's box"
in any way shape or form.

And besides, you're only making this thing as an optimization right?
