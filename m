From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: [PATCH v8 01/16] hashtable: introduce a small and naive hashtable
Date: Wed, 31 Oct 2012 03:24:31 +0000
Message-ID: <20121031032431.GG2616@ZenIV.linux.org.uk>
References: <1351622772-16400-1-git-send-email-levinsasha928@gmail.com>
 <20121030214257.GB2681@htj.dyndns.org>
 <CA+1xoqeCKS2E4TWCUCELjDqV2pWS4v6EyV6K-=w-GRi_K6quiQ@mail.gmail.com>
 <1351646186.4004.41.camel@gandalf.local.home>
 <CA+55aFzFMrOUwdHHJ5-YUtEzTHGvdRosQc+K+trjub0K-w-D3A@mail.gmail.com>
 <20121031022418.GE2616@ZenIV.linux.org.uk>
 <CA+55aFyU30Z2JS9XJ4KTordbAw-2EBVD7xF4K3eAhKVRCJw8YA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org,
	paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org,
	axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	neilb-l3A5Bk7waGM@public.gmane.org, ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org,
	venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFyU30Z2JS9XJ4KTordbAw-2EBVD7xF4K3eAhKVRCJw8YA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 30, 2012 at 07:48:19PM -0700, Linus Torvalds wrote:
> On Tue, Oct 30, 2012 at 7:24 PM, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org> wrote:
> >
> > BTW, how serious have you been back at KS when you were talking about
> > pull requests killing a thousand of lines of code being acceptable
> > at any point in the cycle?
> 
> Well... I'm absolutely a lot more open to pull requests that kill code
> than not, but I have to admit to being a bit more worried about stuff
> like your execve/fork patches that touch very low-level code.
> 
> So I think I'll punt that for 3.8 anyway.

Oh, well... there go my blackmail plans ;-)  Seriously, though, I'm at loss
regarding several embedded architectures - arch/score, in particular,
seems to be completely orphaned.  As far as I can see, it's
	* abandoned by hw vendor (seems like they were planning to push
it game consoles, but that was just before the recession, and...)
	* abandoned by primary maintainer, who isn't employed by said
hw vendor anymore, so his old address had been bouncy for several years.
He had bothered to update it in gcc tree, but hadn't been active there
either for almost as long.  And new address in gcc tree is of form
<name>+gcc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, so using it for kernel-related mail would seem to
be a lousy idea.
	* the second maintainer seems to be nearly MIA as well - all I can
find is Acked-by on one commit.  Cc'ed on the kernel_execve() thread, but...
no signs of life whatsoever.
	* a lot of asm glue is in "apparently never worked" state, starting
with ptrace hookup (it's clearly started its life as a mips clone, but uses
different registers for passing return value, etc.  TIF_SYSCALL_TRACE side of
that thing still assumes MIPS ABI *and* is suffering obvious bitrot)

Sigh...
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
