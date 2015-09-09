From: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 5/6] seccomp: add a way to attach a filter via eBPF fd
Date: Wed, 9 Sep 2015 08:47:24 -0600
Message-ID: <20150909144724.GZ26679@smitten>
References: <1441382664-17437-1-git-send-email-tycho.andersen@canonical.com>
 <1441382664-17437-6-git-send-email-tycho.andersen@canonical.com>
 <CAGXu5jKke44txdYqEgPRrkn8SyWGjJuHxT2qMdq2ztp_16mQyw@mail.gmail.com>
 <55EA95FE.7000006@gmail.com>
 <20150908134044.GV26679@smitten>
 <CAGXu5jKS0yX92XXhL6ZkqMrxkqFpPyyBd7wbsvEEx4rqZ0VG6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAGXu5jKS0yX92XXhL6ZkqMrxkqFpPyyBd7wbsvEEx4rqZ0VG6g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 08, 2015 at 05:07:03PM -0700, Kees Cook wrote:
>
> Yeah, bpf's union looks good. Let's add a "command" flag, though:
> 
> seccomp(SECCOMP_MODE_FILTER_EBPF, int cmd, union, size);
> 
> And this cmd could be ADD_FD or something?
> 
> How's that look?

I think we can drop the size (using the same strategy as bpf() and
checking for zeroes at the end), and keep the same signature for
seccomp(); so:

seccomp(SECCOMP_MODE_FILTER_EBPF, SECCOMP_ADD_BPF_FD, &union)

Yes, I'll use this in the next version.

Tycho
