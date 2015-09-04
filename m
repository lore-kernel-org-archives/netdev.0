From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: Re: [PATCH 3/6] ebpf: add a way to dump an eBPF program
Date: Fri, 4 Sep 2015 15:00:09 -0600
Message-ID: <20150904210009.GQ26679@smitten>
References: <1441382664-17437-1-git-send-email-tycho.andersen@canonical.com>
 <1441382664-17437-4-git-send-email-tycho.andersen@canonical.com>
 <CAGXu5jJ5+EFDRpgJC6U8Y4nvPEh2fivi-TZRNC-4qP9Gi7B7pA@mail.gmail.com>
 <20150904204554.GO26679@smitten>
 <CAGXu5jK20KV2uaUPgy+6SZ-Q8eJFotX9W_kDKuGkjBJQXJDVRg@mail.gmail.com>
 <20150904205821.GE1842@Alexeis-MacBook-Pro-2.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <keescook@chromium.org>,
	Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150904205821.GE1842@Alexeis-MacBook-Pro-2.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 04, 2015 at 01:58:25PM -0700, Alexei Starovoitov wrote:
> On Fri, Sep 04, 2015 at 01:50:55PM -0700, Kees Cook wrote:
> > On Fri, Sep 4, 2015 at 1:45 PM, Tycho Andersen
> > <tycho.andersen@canonical.com> wrote:
> > > On Fri, Sep 04, 2015 at 01:17:30PM -0700, Kees Cook wrote:
> > >> On Fri, Sep 4, 2015 at 9:04 AM, Tycho Andersen
> > >> <tycho.andersen@canonical.com> wrote:
> > >> > This commit adds a way to dump eBPF programs. The initial implementation
> > >> > doesn't support maps, and therefore only allows dumping seccomp ebpf
> > >> > programs which themselves don't currently support maps.
> > >> >
> > >> > We export the GPL bit as well as a unique ID for the program so that
> > >>
> > >> This unique ID appears to be the heap address for the prog. That's a
> > >> huge leak, and should not be done. We don't want to introduce new
> > >> kernel address leaks while we're trying to fix the remaining ones.
> > >> Shouldn't the "unique ID" be the fd itself? I imagine KCMP_FILE
> > >> could be used, for example.
> > >
> > > No; we acquire the fd per process, so if a task installs a filter and
> > > then forks N times, we'll grab N (+1) copies of the filter from N (+1)
> > > different file descriptors. Ideally, we'd have some way to figure out
> > > that these were all the same. Some sort of prog_id is one way,
> > > although there may be others.
> > 
> > If KCMP_FILE or a new KCMP_BPF isn't possible, then we'll probably
> > have to add a unique id (counter) to all bpf programs as they're
> > created.
> 
> I think tweaking KCMP_FILE for anon_inodes should do the trick
> and should work at the end (if it's not working already).

Sounds good. I'll look into that for the next version, thanks.

Tycho
