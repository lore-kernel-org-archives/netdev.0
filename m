From: Oleg Nesterov <oleg@redhat.com>
Subject: oom-kill && frozen()
Date: Tue, 12 Nov 2013 17:56:43 +0100
Message-ID: <20131112165643.GA31278@redhat.com>
References: <1384264396-14550-1-git-send-email-geert@linux-m68k.org> <20131112141314.GQ5056@laptop.programming.kicks-ass.net> <AE90C24D6B3A694183C094C60CF0A2F6026B7405@saturn3.aculab.com> <20131112145243.GU5056@laptop.programming.kicks-ass.net> <20131112162136.GA29065@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Ingo Molnar <mingo@kernel.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>, Tejun Heo <tj@kernel.org>,
	David Rientjes <rientjes@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131112162136.GA29065@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/12, Oleg Nesterov wrote:
>
> I am also wondering if it makes any sense to turn PF_FROZEN into
> TASK_FROZEN, something like (incomplete, probably racy) patch below.
> Note that it actually adds the new state, not the the qualifier.

As for the current usage of PF_FROZEN... David, it seems that
oom_scan_process_thread()->__thaw_task() is dead? Probably this
was fine before, when __thaw_task() cleared the "need to freeze"
condition, iirc it was PF_FROZEN.

But today __thaw_task() can't help, no? the task will simply
schedule() in D state again.

Oleg.
