From: "Michael Kerrisk" <michael.kerrisk-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: [PATCH] alternative to sys_indirect, part 1
Date: Thu, 24 Apr 2008 17:05:45 +0200
Message-ID: <c49095e30804240805ge3f9ae1qbdcf95ed17cbf151@mail.gmail.com>
References: <200804240403.m3O43us8028699@devserv.devel.redhat.com>
	 <20080424112514.055d8071@the-village.bc.nu>
	 <517f3f820804240534r3bbbdc52s52a6dfe3f2d14b7f@mail.gmail.com>
	 <48109DFB.900@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michael Kerrisk" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Alan Cox" <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	"Linus Torvalds" <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	michael.kerrisk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Ulrich Drepper" <drepper-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <48109DFB.900-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Content-Disposition: inline
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 24, 2008 at 4:49 PM, Ulrich Drepper <drepper-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
>  Hash: SHA1
>
>
>  Michael Kerrisk wrote:
>  > * dup2() -- use fcntl(F_DUPFD) instead
>
>  Wrong.  You cannot implement dup2 with fcntl since the latter won't use
>  a file descriptor which is already in use.

True.  One could add a flag to fcntl() to provide that behavior.

>  > So the alternative to sys_indirect(), at least for the purpose of
>  > O_CLOEXEC and similar, would be to create 5 new system calls (or six,
>  > if one finds the signalfd() hack too ugly, which perhaps it is; or 7
>  > if one doesn't like Alan's suggestion for socket()
>
>  Without changing the socket interfaces (plural, socketpair) there would

Yes, I overlooked socket pair()...

>  have to be 7 new syscalls, with changing socket* to an IMO cleaner
>  interface 9.
>
>
>  Or we just add sys_indirect (which is also usable for other syscall
>  extensions, not just the CLOEXEC stuff) and let userlevel (i.e., me)
>  worry about adding new interfaces to libc.  As you can see, for the more
>  recent interfaces like signalfd I have already added an additional
>  parameter so the number of interface changes would be reduced.
>
>  Somebody please make a call and then let's go on with life.  I don't
>  care much either way anymore.  I do hope nobody thinks this is an issue
>  which can be completely ignored (see, e.g., the bug I pointed to the
>  other day).

Since I had to go search, here it is again
http://bugzilla.redhat.com/show_bug.cgi?id=443321
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
