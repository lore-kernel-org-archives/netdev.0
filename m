From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: v2 of seccomp filter c/r patches
Date: Thu, 10 Sep 2015 19:50:39 -0700
Message-ID: <20150911025036.GB4903@Alexeis-MacBook-Pro-2.local>
References: <1441930862-14347-1-git-send-email-tycho.andersen@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1441930862-14347-1-git-send-email-tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 10, 2015 at 06:20:57PM -0600, Tycho Andersen wrote:
> Hi all,
> 
> Here is v2 of the seccomp filter c/r set. The patch notes have individual
> changes from the last series, but there are two points not noted:
> 
> * The series still does not allow us to correctly restore state for programs
>   that will use SECCOMP_FILTER_FLAG_TSYNC in the future. Given that we want to
>   keep seccomp_filter's identity, I think something along the lines of another
>   seccomp command like SECCOMP_INHERIT_PARENT is needed (although I'm not sure
>   if this can even be done yet). In addition, we'll need a kcmp command for
>   figuring out if filters are the same, although this too needs to compare
>   seccomp_filter objects, so it's a little screwy. Any thoughts on how to do
>   this nicely are welcome.
> 
> * I've dropped the bpf converter bug from the set and will submit it
>   separately.
> 
> Alexei mentioned that this should go via net-next to minimize cross-tree
> conflicts. Does that make sense here?

Having looked at the set again I already see conflicts in net/core/filter.c
and in linux/bpf.h with things myself and others are working on for net-next.
So I think it makes the most sense to get the whole set via net-next,
since seccomp bits look limited comparing to bpf changes.
Otherwise the merge window will be unpleasant.
