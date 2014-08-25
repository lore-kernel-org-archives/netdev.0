From: Cong Wang <cwang-xCSkyg8dI+0RB7SZvlqPiA@public.gmane.org>
Subject: Re: [PATCH v5 net-next 06/29] bpf: add lookup/update/delete/iterate
 methods to BPF maps
Date: Mon, 25 Aug 2014 14:33:48 -0700
Message-ID: <CAHA+R7MTJcsDpw=5P7hOsVf_pEOEZX_=cLrcw4ep4xntUxk=3Q@mail.gmail.com>
References: <1408911690-7598-1-git-send-email-ast@plumgrid.com>
	<1408911690-7598-7-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Brendan Gregg <brendan.d.gregg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1408911690-7598-7-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 24, 2014 at 1:21 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
> 'maps' is a generic storage of different types for sharing data between kernel
> and userspace.
>
> The maps are accessed from user space via BPF syscall, which has commands:
>
> - create a map with given type and attributes
>   fd = bpf_map_create(map_type, struct nlattr *attr, int len)
>   returns fd or negative error
>
> - lookup key in a given map referenced by fd
>   err = bpf_map_lookup_elem(int fd, void *key, void *value)
>   returns zero and stores found elem into value or negative error
>
> - create or update key/value pair in a given map
>   err = bpf_map_update_elem(int fd, void *key, void *value)
>   returns zero or negative error
>
> - find and delete element by key in a given map
>   err = bpf_map_delete_elem(int fd, void *key)
>
> - iterate map elements (based on input key return next_key)
>   err = bpf_map_get_next_key(int fd, void *key, void *next_key)


I think you need to document the bpf() syscall instead of wrappers on it,
from a developer's point of view. You will anyway need to document a new
syscall with a man page as a general rule.

In the changelog I mean something like:

err = bpf(BPF_MAP_LOOKUP_ELEM, ...);
