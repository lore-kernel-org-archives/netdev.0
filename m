From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Tue, 20 Dec 2016 20:01:49 -0800
Message-ID: <20161221040147.GA23140@ast-mbp.thefacebook.com>
References: <20161219205631.GA31242@ast-mbp.thefacebook.com>
 <CALCETrWr5XMkexdGp7HdkiLkQV=P9ycj+sNO7xWSRoCVxihVZA@mail.gmail.com>
 <20161220000254.GA58895@ast-mbp.thefacebook.com>
 <CALCETrU1_bDVLfokQ7zasHVmeq7S-R+603GEw59V_wuj4eE1hw@mail.gmail.com>
 <20161220031802.GA77838@ast-mbp.thefacebook.com>
 <CALCETrXymvAo-9zhQe=amToz_fs9XGniK2KLZv5Fxc66qcUx6A@mail.gmail.com>
 <bdc18fe4-f90d-49f0-d0a6-a28f87335df2@zonque.org>
 <CALCETrXyp2ddf4HRsEoN=qEwTBaezOUX2XWj6nxPcbc4t13svw@mail.gmail.com>
 <9e378fb1-23ff-a239-d915-3d9aa26a999e@zonque.org>
 <CALCETrVhjiRMSkvmMDgq_O7niWHiRcvjq-my8nYS9_s8JDye1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Mack <daniel@zonque.org>, Andy Lutomirski <luto@kernel.org>,
        =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>,
        Kees Cook <keescook@chromium.org>, Jann Horn <jann@thejh.net>,
        Tejun Heo <tj@kernel.org>, David Ahern <dsahern@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Thomas Graf <tgraf@suug.ch>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Linux API <linux-api@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALCETrVhjiRMSkvmMDgq_O7niWHiRcvjq-my8nYS9_s8JDye1g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 20, 2016 at 10:49:25AM -0800, Andy Lutomirski wrote:
> >> FWIW, everywhere I say ioctl(), the bpf() syscall would be okay, too.
> >> It doesn't make a semantic difference, except that I dislike
> >> BPF_PROG_DETACH because that particular command isn't BPF-specific at
> >> all.
> >
> > Well, I think it is; it pops the bpf program from a target and drops the
> > reference on it. It's not much code, but it's certainly bpf-specific.
> 
> I mean the interface isn't bpf-specific.  If there was something that
> wasn't bpf attached to the target, you'd still want an API to detach
> it.

This discussion won't go anywhere while you keep thinking that this api
has to be generalized. As I explained several times earlier
BPF_CGROUP_INET_SOCK_CREATE hook is bpf specific. There is nothing
in the kernel that can take advantage of it today, so by definition
the hook is bpf specific. Period. Saying that something in the future
may come along that would want to use that is like saying I want
to design the generic steering wheel for any car that will ever need it.

Hence if you want to change 'target_fd' in BPF_PROG_ATTACH/DETACH cmds
from being fd of open("cgroupdir") to fd of open("cgroupdir/cgroup.bpf")
file inside it then I'm ok with that.
All other proposals with non-extensible ioctls() and crazy text based
per-hook permissions is nack.
