From: "Michael Kerrisk" <mtk.manpages-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: [PATCH] reintroduce accept4
Date: Thu, 13 Nov 2008 17:02:28 -0500
Message-ID: <cfd18e0f0811131402j7ec6a60cq462916cc9715b9aa@mail.gmail.com>
References: <200810261641.m9QGfotr024285@hs20-bc2-1.build.redhat.com>
	 <517f3f820811131351l1305b2d2u43ab4e0601d97f93@mail.gmail.com>
Reply-To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Subrata Modak" <subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Ulrich Drepper" <drepper-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Davide Libenzi" <davidel-AhlLAIvw+VEjIGhXcJzhZg@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Roland McGrath" <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Oleg Nesterov" <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>,
	"Christoph Hellwig" <hch-jcswGhMUV9g@public.gmane.org>,
	"David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, "Alan Cox" <alan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Jakub Jelinek" <jakub-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: "Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <517f3f820811131351l1305b2d2u43ab4e0601d97f93-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hit the send button a little early on my last mail.  Just to complete one piece:

> My only argument is with the name of the new sysytem call.

... Each of these new system calls (accept4(), dup3(), evenfd2(),
signalfd4(), inotify_init1(), epoll_create1(), pipe2()) has a name
that's based on the number of arguments it has.  This follows a
convention that was used in a few traditional Unix system calls, e.g.,
wait3(), wait4(), dup2().  However, it's probably a mistake since:

a) The glibc interfaces can have different numbers of arguments from
the system call

b) In the future, we might use the new bits in the flags argument to
signal the presence of additional arguments for the call, in which
case the number in the name no longer matches the number of arguments
in the call signature.

In the end, names like acceptx(), dupx(), ... or acceptfl(), duplf(),
... or somesuch would probably have been better.  But given that we
already added the other system calls, it doesn't seem worth bothering
to change things for accept4().

Cheers,

Michael
--
To unsubscribe from this list: send the line "unsubscribe linux-api" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
