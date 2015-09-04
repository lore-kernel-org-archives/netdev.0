From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 4/6] seccomp: add a way to access filters via bpf fds
Date: Fri, 4 Sep 2015 13:29:49 -0700
Message-ID: <20150904202946.GC1842@Alexeis-MacBook-Pro-2.local>
References: <1441382664-17437-1-git-send-email-tycho.andersen@canonical.com>
 <1441382664-17437-5-git-send-email-tycho.andersen@canonical.com>
 <CAGXu5j+B_ENy7txG4nndpeOh_z_3d7bBxeJD-WS_yPBZiuZ7rg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tycho Andersen <tycho.andersen@canonical.com>,
	Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAGXu5j+B_ENy7txG4nndpeOh_z_3d7bBxeJD-WS_yPBZiuZ7rg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 04, 2015 at 01:26:42PM -0700, Kees Cook wrote:
> On Fri, Sep 4, 2015 at 9:04 AM, Tycho Andersen
> <tycho.andersen@canonical.com> wrote:
> > This patch adds a way for a process that is "real root" to access the
> > seccomp filters of another process. The process first does a
> > PTRACE_SECCOMP_GET_FILTER_FD to get an fd with that process' seccomp filter
> > attached, and then iterates on this with PTRACE_SECCOMP_NEXT_FILTER using
> > bpf(BPF_PROG_DUMP) to dump the actual program at each step.
> 
> Why is this a new ptrace interface instead of a new seccomp interface?
> I would expect this to only be valid for "current", otherwise we could
> run into races as the ptracee adds filters. i.e. it is not safe to
> examine seccomp filters from tasks other than current.

same question.
I thought we discussed to add a command to seccomp() syscall for that?
