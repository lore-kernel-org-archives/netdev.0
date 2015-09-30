From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH v3 2/5] seccomp: add the concept of a seccomp filter FD
Date: Wed, 30 Sep 2015 11:27:34 -0700
Message-ID: <CALCETrXkG6QCx9ptyN+VWrjgoTvwZAOfa-pWhS4iCZ=fpm6YnQ@mail.gmail.com>
References: <1443636820-17083-1-git-send-email-tycho.andersen@canonical.com> <1443636820-17083-3-git-send-email-tycho.andersen@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1443636820-17083-3-git-send-email-tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 30, 2015 at 11:13 AM, Tycho Andersen
<tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
> This patch introduces the concept of a seccomp fd, with a similar interface
> and usage to ebpf fds. Initially, one is allowed to create, install, and
> dump these fds. Any manipulation of seccomp fds requires users to be root
> in their own user namespace, matching the checks done for
> SECCOMP_SET_MODE_FILTER.
>
> Installing a filterfd has some gotchas, though. Andy mentioned previously
> that we should restrict installation to filter fds whose parent is already
> in the filter tree. This doesn't quite work in the case of created seccomp
> fds, since once you install a filter fd, you can't install any other filter
> fd since it has no parent and there is no way to "pre-chain" filters before
> installing them.

ISTM, if we like the seccomp fd approach, we should have them be
created with a parent already set.  IOW the default should be that
their parent is the creator's seccomp fd and, if needed, creators
could specify a different parent.

--Andy
