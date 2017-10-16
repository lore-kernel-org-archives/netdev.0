From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH 3/3] bpf: Make sure that ->comm does not change under us.
Date: Mon, 16 Oct 2017 23:10:37 +0200
Message-ID: <2144178.MA8iAIlUE0@blindfold>
References: <20171016181856.12497-1-richard@nod.at> <3636052.F7cf4ubS1t@blindfold> <59E51E4E.4060009@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        ast@kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <59E51E4E.4060009@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Montag, 16. Oktober 2017, 23:02:06 CEST schrieb Daniel Borkmann:
> On 10/16/2017 10:55 PM, Richard Weinberger wrote:
> > Am Montag, 16. Oktober 2017, 22:50:43 CEST schrieb Daniel Borkmann:
> >>>    	struct task_struct *task = current;
> >>> 
> >>> +	task_lock(task);
> >>> 
> >>>    	strncpy(buf, task->comm, size);
> >>> 
> >>> +	task_unlock(task);
> >> 
> >> Wouldn't this potentially lead to a deadlock? E.g. you attach yourself
> >> to task_lock() / spin_lock() / etc, and then the BPF prog triggers the
> >> bpf_get_current_comm() taking the lock again ...
> > 
> > Yes, but doesn't the same apply to the use case when I attach to strncpy()
> > and run bpf_get_current_comm()?
> 
> You mean due to recursion? In that case trace_call_bpf() would bail out
> due to the bpf_prog_active counter.

Ah, that's true.
So, when someone wants to use bpf_get_current_comm() while tracing task_lock,
we have a problem. I agree.
On the other hand, without locking the function may return wrong results.

Thanks,
//richard
