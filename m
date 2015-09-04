From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: Re: [PATCH 3/6] ebpf: add a way to dump an eBPF program
Date: Fri, 4 Sep 2015 14:45:54 -0600
Message-ID: <20150904204554.GO26679@smitten>
References: <1441382664-17437-1-git-send-email-tycho.andersen@canonical.com>
 <1441382664-17437-4-git-send-email-tycho.andersen@canonical.com>
 <CAGXu5jJ5+EFDRpgJC6U8Y4nvPEh2fivi-TZRNC-4qP9Gi7B7pA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@kernel.org>,
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
In-Reply-To: <CAGXu5jJ5+EFDRpgJC6U8Y4nvPEh2fivi-TZRNC-4qP9Gi7B7pA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 04, 2015 at 01:17:30PM -0700, Kees Cook wrote:
> On Fri, Sep 4, 2015 at 9:04 AM, Tycho Andersen
> <tycho.andersen@canonical.com> wrote:
> > This commit adds a way to dump eBPF programs. The initial implementation
> > doesn't support maps, and therefore only allows dumping seccomp ebpf
> > programs which themselves don't currently support maps.
> >
> > We export the GPL bit as well as a unique ID for the program so that
> 
> This unique ID appears to be the heap address for the prog. That's a
> huge leak, and should not be done. We don't want to introduce new
> kernel address leaks while we're trying to fix the remaining ones.
> Shouldn't the "unique ID" be the fd itself? I imagine KCMP_FILE
> could be used, for example.

No; we acquire the fd per process, so if a task installs a filter and
then forks N times, we'll grab N (+1) copies of the filter from N (+1)
different file descriptors. Ideally, we'd have some way to figure out
that these were all the same. Some sort of prog_id is one way,
although there may be others.

Tycho
