From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: Re: [PATCH 1/6] ebpf: add a seccomp program type
Date: Wed, 9 Sep 2015 11:31:20 -0600
Message-ID: <20150909173120.GC26679@smitten>
References: <1441382664-17437-2-git-send-email-tycho.andersen@canonical.com>
 <CAGXu5j+9YvL6XzX=x8krZbdJXFpe-3FuMu=hAZX9Ew=hYyuK7Q@mail.gmail.com>
 <20150904210615.GR26679@smitten>
 <CAGXu5jKGBuD15KBfXKoYbGB40cNsbh=Dz8GM=bmUL-oECRhzxA@mail.gmail.com>
 <20150909155035.GA26679@smitten>
 <20150909160744.GA3526@Alexeis-MBP-2.westell.com>
 <55F059C7.9070105@iogearbox.net>
 <CAGXu5jJVNfBZ1ugmpA3FCnG4++EPLfRhjSNBi3TtA0xGK=fzsg@mail.gmail.com>
 <20150909165225.GA3562@Alexeis-MBP-2.westell.com>
 <CAGXu5jJGiCBW1UE8SzUtJ2bRvjxEMRx3KU-78S8qQM0YRV+3Sg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAGXu5jJGiCBW1UE8SzUtJ2bRvjxEMRx3KU-78S8qQM0YRV+3Sg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 09, 2015 at 10:27:08AM -0700, Kees Cook wrote:
> On Wed, Sep 9, 2015 at 9:52 AM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
> > On Wed, Sep 09, 2015 at 09:37:51AM -0700, Kees Cook wrote:
> >> On Wed, Sep 9, 2015 at 9:09 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> >> > On 09/09/2015 06:07 PM, Alexei Starovoitov wrote:
> >> >>
> >> >> On Wed, Sep 09, 2015 at 09:50:35AM -0600, Tycho Andersen wrote:
> >> >
> >> > [...]
> >> >>>
> >> >>> Thoughts?
> >> >>
> >> >>
> >> >> Please do not add any per-instruction hacks. None of them are
> >> >> necessary. Classic had to do extra ugly checks in seccomp only
> >> >> because verifier wasn't flexible enough.
> >> >> If you don't want to see any BPF_CALL in seccomp, just have
> >> >> empty get_func_proto() callback for BPF_PROG_TYPE_SECCOMP
> >> >> and verifier will reject all calls.
> >> >> Currently we have only two non-generic instrucitons
> >> >> LD_ABS and LD_IND that are avaialable for sockets/TC only,
> >> >> because these are legacy instructions and we had to make
> >> >> exceptions for them.
> >> >
> >> > Yep, +1.
> >>
> >> Hrmpf. This adds to the cognitive load for accepting this patch
> >> series. :P Now I have to convince myself that there is no additional
> >> exposure to seccomp by using the entire set of eBPF instructions.
> >> While I'm pretty sure it'll be fine, I really don't want to risk being
> >> wrong and opening a hole here. I will spend some time looking at the
> >> new eBPF instructions...
> >
> > note, as was discussed many times before, there is no pointer leak
> > prevention pass yet, so eBPF is root only.
> > Once the pass is complete it will prevent passing addresses to
> > functions, storing them in maps and returning from the program.
> 
> Tycho, are you building new eBPF filters as the root user and then
> attaching them later?

Yep, exactly.

> I was imagining you were going to need this entirely as non-root.

We can't exactly because of the real root restriction on bpf(). So we
just open the bpf fds when we're real root and keep them until the
very end of the restore when we finally install the seccomp filters.
Not ideal, of course, but I assume we can change how this works once
bpf() deemed safe for non-root.

Tycho
