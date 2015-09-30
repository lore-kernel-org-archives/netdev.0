From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v3 2/5] seccomp: add the concept of a seccomp filter FD
Date: Wed, 30 Sep 2015 11:47:28 -0700
Message-ID: <CALCETrX1uW-jM4SJEuxLeDGhqg6_-=K5_RM8e9yNUn2m8uLkJQ@mail.gmail.com>
References: <1443636820-17083-1-git-send-email-tycho.andersen@canonical.com>
 <1443636820-17083-3-git-send-email-tycho.andersen@canonical.com>
 <CALCETrXkG6QCx9ptyN+VWrjgoTvwZAOfa-pWhS4iCZ=fpm6YnQ@mail.gmail.com> <20150930183632.GA23065@smitten>
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
In-Reply-To: <20150930183632.GA23065@smitten>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 30, 2015 at 11:36 AM, Tycho Andersen
<tycho.andersen@canonical.com> wrote:
> On Wed, Sep 30, 2015 at 11:27:34AM -0700, Andy Lutomirski wrote:
>> On Wed, Sep 30, 2015 at 11:13 AM, Tycho Andersen
>> <tycho.andersen@canonical.com> wrote:
>> > This patch introduces the concept of a seccomp fd, with a similar interface
>> > and usage to ebpf fds. Initially, one is allowed to create, install, and
>> > dump these fds. Any manipulation of seccomp fds requires users to be root
>> > in their own user namespace, matching the checks done for
>> > SECCOMP_SET_MODE_FILTER.
>> >
>> > Installing a filterfd has some gotchas, though. Andy mentioned previously
>> > that we should restrict installation to filter fds whose parent is already
>> > in the filter tree. This doesn't quite work in the case of created seccomp
>> > fds, since once you install a filter fd, you can't install any other filter
>> > fd since it has no parent and there is no way to "pre-chain" filters before
>> > installing them.
>>
>> ISTM, if we like the seccomp fd approach, we should have them be
>> created with a parent already set.  IOW the default should be that
>> their parent is the creator's seccomp fd and, if needed, creators
>> could specify a different parent.
>
> Allowing people doing SECCOMP_FD_NEW to specify a parent fd would
> work. Then we can disallow installing a seccomp fd if its parent is
> not the current filter, and get rid of the whole mess with prev
> locking and all that.
>

Yes, please.

--Andy
