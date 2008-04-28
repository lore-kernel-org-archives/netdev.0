From: "Michael Kerrisk" <mtk.manpages@googlemail.com>
Subject: Re: [PATCH] paccept, socket, socketpair w/flags
Date: Mon, 28 Apr 2008 17:29:07 +0200
Message-ID: <cfd18e0f0804280829w3659747alb2100c46e50b470c@mail.gmail.com>
References: <200804262224.m3QMOP3a006296@devserv.devel.redhat.com>
	 <517f3f820804280252h753c8cacv7fe9580f96dcf1ce@mail.gmail.com>
	 <4815DB8B.7060606@redhat.com>
	 <cfd18e0f0804280751x21833b51y4b1f6f7ce3201d0d@mail.gmail.com>
	 <4815E99B.2010903@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michael Kerrisk" <mtk.manpages@gmail.com>,
	"Alan Cox" <alan@lxorguk.ukuu.org.uk>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, torvalds@linux-foundation.org
To: "Ulrich Drepper" <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0708.google.com ([209.85.198.246]:59222 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932271AbYD1P3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 11:29:08 -0400
Received: by rv-out-0506.google.com with SMTP id k29so2943424rvb.1
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 08:29:07 -0700 (PDT)
In-Reply-To: <4815E99B.2010903@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 28, 2008 at 5:13 PM, Ulrich Drepper <drepper@redhat.com> wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>
> Michael Kerrisk wrote:
> > You have said it would be cleaner to have new syscalls for socket()
> > and socketpair().  I understand your reasoning for that to be that
> > doing so is cleaner than overloading the type argument of the existing
> > versions of these syscalls.  I agree.  So, since you are adding new
> > syscalls for all of the other interfaces, why not do it for these two
> > syscalls also?
>
> If the range of the existing parameter can indeed be restricted as
> needed for the flags it is the better approach for programmers since all
> that is needed for a programmer to do is to write
>
>
>   fd = socket(PF_INET, SOCK_STREAM|SOCK_CLOEXEC, 0);
>   if (fd == -1 && errno == EINVAL)
>     {
>       fd = socket(PF_INET, SOCK_STREAM, 0);
>       if (fd != -1)
>         fcntl(fd, F_SETFD, FD_CLOEXEC);
>     }
>
> No autoconf code needed to detect the presence of a new function.  You
> can even imagine that convenience libraries will do the above
> automatically (not libc, though, where you want to recognize this
> situation).

Okay -- makes sense.

> > Okay -- I see your point (and I didn't read your patches closely
> > enough).  However, the rationale for the implementations proposed to
> > date isn't very clear.  So far we have the following new flags:
> >
> > timerfd_create() -- TFD_CLOEXEC
> > signalfd4() -- SFD_CLOEXEC
> > eventfd2() -- EFD_CLOEXEC
> > epoll_create2() -- EPOLL_CLOEXEC
> > open() (and openat()), dup3() -- all use O_CLOEXEC
> > socketpair(), socket(), paccept -- all use SOCK_CLOEXEC
> > pipe2() -- to be determined
>
> Use O_CLOEXEC, normal filesystem operation.

What happens come the day that we want to have a flag that is specific
to, say, pipe2()?  Will it be a new O_ flag? or a new PIPE_ flag?

> > inotify_init2() -- to be determined
>
> New flag.
>
>
> > It would help if you laid out your reasoning for creating distinct
> > flags for some syscalls but not others.  For example, is the
> > assumption here that socketpair(), socket(), and paccept() will always
> > use the same set of flags?
>
> Yes, they are all related interfaces.  Using the same name indicates
> similarity.

Sorry -- I still don't get this -- how is it guaranteed that these
syscalls will always use the same set of flags?  For example, I could
imagine that one day, we might want a flag that is specific to
paccept() -- you seem to be saying that would never be the case?

> And just to complicate things even more:
>
> if we'd go with sys_indirect we can have single way to specify
> close-on-exec for all syscalls.  That would be at the syscall level.  At
> the API level we'd still need separate names and possibly values.

Yes.

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Found a bug? http://www.kernel.org/doc/man-pages/reporting_bugs.html
