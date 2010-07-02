From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH repost] sched: export sched_set/getaffinity to modules
Date: Fri, 2 Jul 2010 23:06:37 +0200
Message-ID: <20100702210637.GA12433@redhat.com>
References: <1277988395.1917.47.camel@laptop> <20100701130816.GB32223@redhat.com> <1277991024.1917.108.camel@laptop> <20100701133956.GD32223@redhat.com> <4C2CA5C5.4040402@kernel.org> <20100701144624.GA11171@redhat.com> <4C2CABF2.2020801@kernel.org> <1277996135.1917.198.camel@laptop> <4C2E2987.9040702@us.ibm.com> <1278094270.1917.288.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>, Tejun Heo <tj@kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andi Kleen <ak@linux.intel.com>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1278094270.1917.288.camel@laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/02, Peter Zijlstra wrote:
>
> On Fri, 2010-07-02 at 11:01 -0700, Sridhar Samudrala wrote:
> >
> >  Does  it (Tejun's kthread_clone() patch) also  inherit the
> > cgroup of the caller?
>
> Of course, its a simple do_fork() which inherits everything just as you
> would expect from a similar sys_clone()/sys_fork() call.

Yes. And I'm afraid it can inherit more than we want. IIUC, this is called
from ioctl(), right?

Then the new thread becomes the natural child of the caller, and it shares
->mm with the parent. And files, dup_fd() without CLONE_FS.

Signals. Say, if you send SIGKILL to this new thread, it can't sleep in
TASK_INTERRUPTIBLE or KILLABLE after that. And this SIGKILL can be sent
just because the parent gets SIGQUIT or abother coredumpable signal.
Or the new thread can recieve SIGSTOP via ^Z.

Perhaps this is OK, I do not know. Just to remind that kernel_thread()
is merely clone(CLONE_VM).

Oleg.
