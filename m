From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v3 4/5] kcmp: add KCMP_FILE_PRIVATE_DATA
Date: Wed, 30 Sep 2015 14:48:47 -0700
Message-ID: <CALCETrW9-bpUd+quFF7fBjbBLS84VDT4dmBS=-cVe6+9S-DenA@mail.gmail.com>
References: <1443636820-17083-1-git-send-email-tycho.andersen@canonical.com>
 <1443636820-17083-5-git-send-email-tycho.andersen@canonical.com>
 <CALCETrUosV+ND1BC-qH3xZMaLwnex50SvMhaSa3FQ19oy1MBVg@mail.gmail.com>
 <20150930184129.GB23065@smitten> <CALCETrWjLGLAnf5_tCZohKYtTDi5Jo=bk_BkchTgXi8Bzz9YDA@mail.gmail.com>
 <20150930185504.GC23065@smitten> <CALCETrWx_yCF7o6ZnbeoDqw-Fxa3GzARX30SZWeg40FMGqR25Q@mail.gmail.com>
 <20150930213909.GD23065@smitten>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kees Cook <keescook@chromium.org>,
	Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux API <linux-api@vger.kernel.org>
To: Tycho Andersen <tycho.andersen@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150930213909.GD23065@smitten>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 30, 2015 at 2:39 PM, Tycho Andersen
<tycho.andersen@canonical.com> wrote:
> On Wed, Sep 30, 2015 at 11:56:25AM -0700, Andy Lutomirski wrote:
>> On Wed, Sep 30, 2015 at 11:55 AM, Tycho Andersen
>> <tycho.andersen@canonical.com> wrote:
>> > On Wed, Sep 30, 2015 at 11:47:05AM -0700, Andy Lutomirski wrote:
>> >> On Wed, Sep 30, 2015 at 11:41 AM, Tycho Andersen
>> >> <tycho.andersen@canonical.com> wrote:
>> >> > On Wed, Sep 30, 2015 at 11:25:41AM -0700, Andy Lutomirski wrote:
>> >> >> On Wed, Sep 30, 2015 at 11:13 AM, Tycho Andersen
>> >> >> <tycho.andersen@canonical.com> wrote:
>> >> >> > This command allows comparing the underling private data of two fds. This
>> >> >> > is useful e.g. to find out if a seccomp filter is inherited, since struct
>> >> >> > seccomp_filter are unique across tasks and are the private_data seccomp
>> >> >> > fds.
>> >> >>
>> >> >> This is very implementation-specific and may have nasty ABI
>> >> >> consequences far outside seccomp.  Let's do something specific to
>> >> >> seccomp and/or eBPF.
>> >> >
>> >> > We could change the name to a less generic KCMP_SECCOMP_FD or
>> >> > something, but without some sort of GUID on each struct
>> >> > seccomp_filter, the implementation would be effectively the same as it
>> >> > is today. Is that enough, or do we need a GUID?
>> >> >
>> >>
>> >> I don't care about the GUID.  I think we should name it
>> >> KCMP_SECCOMP_FD and make it only work on seccomp fds.
>> >
>> > Ok, I can do that.
>> >
>> >> Alternatively, we could figure out why KCMP_FILE doesn't do the trick
>> >> and consider fixing it.  IMO it's really too bad that struct file is
>> >> so heavyweight that we can't really just embed one in all kinds of
>> >> structures.
>> >
>> > The problem is that KCMP_FILE compares the file objects themselves,
>> > instead of the underlying data. If I ask for a seccomp fd for filter 0
>> > twice, I'll have two different file objects and they won't be equal. I
>> > suppose we could add some special logic inside KCMP_FILE to compare
>> > the underlying data in special cases (seccomp, ebpf, others?), but it
>> > seems cleaner to have a separate command as you described above.
>> >
>>
>> What I meant was that maybe we could get the two requests to actually
>> produce the same struct file.  But that could get very messy
>> memory-wise.
>
> I see. The attached patch seems to work with KCMP_FILE and doesn't
> look too bad if you don't mind the circular references. What do you
> think?
>

Could be reasonable.  I'm not that well versed on what fd_release
does.  Are we guaranteed that it's called when the last fd goes away
even if the struct file is pinned by the struct seccomp filter but is
otherwise unreferenced?

Kees?

How many of you will be at KS?

--Andy

> Tycho



-- 
Andy Lutomirski
AMA Capital Management, LLC
