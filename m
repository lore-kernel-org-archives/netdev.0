From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf, perf: delay release of BPF prog after grace
 period
Date: Wed, 29 Jun 2016 05:43:33 -0400 (EDT)
Message-ID: <20160629.054333.288595753337307108.davem@davemloft.net>
References: <7b2f4311ea7b4d0acc0042b49b8443702f1d1a70.1467055933.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	alexei.starovoitov@gmail.com, jann@thejh.net
To: daniel@iogearbox.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7b2f4311ea7b4d0acc0042b49b8443702f1d1a70.1467055933.git.daniel@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon, 27 Jun 2016 21:38:11 +0200

> Commit dead9f29ddcc ("perf: Fix race in BPF program unregister") moved
> destruction of BPF program from free_event_rcu() callback to __free_event(),
> which is problematic if used with tail calls: if prog A is attached as
> trace event directly, but at the same time present in a tail call map used
> by another trace event program elsewhere, then we need to delay destruction
> via RCU grace period since it can still be in use by the program doing the
> tail call (the prog first needs to be dropped from the tail call map, then
> trace event with prog A attached destroyed, so we get immediate destruction).
> 
> Fixes: dead9f29ddcc ("perf: Fix race in BPF program unregister")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> Cc: Jann Horn <jann@thejh.net>

Applied and queued up for -stable, thanks Daniel.
