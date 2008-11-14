From: "Michael Kerrisk" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] reintroduce accept4
Date: Fri, 14 Nov 2008 10:24:06 -0500
Message-ID: <517f3f820811140724x43fcc114o434b384fbeb6449e@mail.gmail.com>
References: <200810261641.m9QGfotr024285@hs20-bc2-1.build.redhat.com>
	 <517f3f820811131351l1305b2d2u43ab4e0601d97f93@mail.gmail.com>
	 <20081113140541.23754cad.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	drepper-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davidel-AhlLAIvw+VEjIGhXcJzhZg@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org,
	hch-jcswGhMUV9g@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, alan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jakub-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: "Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20081113140541.23754cad.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Content-Disposition: inline
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>> Andrew, you noted a lack of explanation accompanying the original
>> patch.  Here's something to fill the gap, and which may be suitable
>> for the changelog.
>>
>> ==
>> Introduce a new accept4() system call.  The addition of this system
>> call matches analogous changes in 2.6.27 (dup3(), evenfd2(),
>> signalfd4(), inotify_init1(), epoll_create1(), pipe2()) which added
>> new system calls that differed from analogous traditional system calls
>> in adding a flags argument that can be used to access additional
>> functionality. The accept4() system call is exactly the same as
>> accept(), except that it adds a flags bit-mask argument.  Two flags
>> are initially implemented.  (Most of the new system calls in 2.6.27
>> also had both of these flags.)  SOCK_CLOEXEC causes the close-on-exec
>> (FD_CLOEXEC) flag to be enabled for the new file descriptor returned
>> by accept4().  This is a useful security feature to avoid leaking
>> information in a multithreaded program where one thread is doing an
>> accept() at the same time as another thread is doing a fork() plus
>> exec().  (More details here:
>> http://udrepper.livejournal.com/20407.html "Secure File Descriptor
>> Handling", Ulrich Drepper)  The other flag is SOCK_NONBLOCK, which
>> causes the O_NONBLOCK flag to be enabled on the new open file
>> description created by accept4().  (This flag is merely a convenience,
>> saving the use of additional calls fcntl(F_GETFL) and fcntl (F_SETFL)
>> to achieve the same result.)
>
> I replaced the existing changelog with the above (plus some paragraph
> breaks ;)).  Will add the new test app when it comes along.

Git allows paragraph breaks in changelogs?!  You gotta love technology ;-).

-- 
Michael Kerrisk Linux man-pages maintainer;
http://www.kernel.org/doc/man-pages/ Found a documentation bug?
http://www.kernel.org/doc/man-pages/reporting_bugs.html
--
To unsubscribe from this list: send the line "unsubscribe linux-api" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
