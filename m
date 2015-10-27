From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next] seccomp, ptrace: add support for dumping
 seccomp filters
Date: Mon, 26 Oct 2015 20:39:50 -0700
Message-ID: <20151027033949.GA26775@Alexeis-MacBook-Pro.local>
References: <1445905439-25449-1-git-send-email-tycho.andersen@canonical.com>
 <1445905439-25449-2-git-send-email-tycho.andersen@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1445905439-25449-2-git-send-email-tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 27, 2015 at 09:23:59AM +0900, Tycho Andersen wrote:
> This patch adds support for dumping a process' (classic BPF) seccomp
> filters via ptrace.
> 
> PTRACE_SECCOMP_GET_FILTER allows the tracer to dump the user's classic BPF
> seccomp filters. addr should be an integer which represents the ith seccomp
> filter (0 is the most recently installed filter). data should be a struct
> sock_filter * with enough room for the ith filter, or NULL, in which case
> the filter is not saved. The return value for this command is the number of
> BPF instructions the program represents, or negative in the case of errors.
> Command specific errors are ENOENT: which indicates that there is no ith
> filter in this seccomp tree, and EMEDIUMTYPE, which indicates that the ith
> filter was not installed as a classic BPF filter.
> 
> A caveat with this approach is that there is no way to get explicitly at
> the heirarchy of seccomp filters, and users need to memcmp() filters to
> decide which are inherited. This means that a task which installs two of
> the same filter can potentially confuse users of this interface.
> 
> v2: * make save_orig const
>     * check that the orig_prog exists (not necessary right now, but when
>        grows eBPF support it will be)
>     * s/n/filter_off and make it an unsigned long to match ptrace
>     * count "down" the tree instead of "up" when passing a filter offset
> 
> v3: * don't take the current task's lock for inspecting its seccomp mode
>     * use a 0x42** constant for the ptrace command value
> 
> v4: * don't copy to userspace while holding spinlocks
> 
> v5: * add another condition to WARN_ON
> 
> v6: * rebase on net-next
> 
> Signed-off-by: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Acked-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> CC: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> Reviewed-by: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> CC: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
> CC: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> CC: Serge E. Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
> CC: Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> CC: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>

Looks fine.
Acked-by: Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
