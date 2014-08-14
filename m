From: Brendan Gregg <brendan.d.gregg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH RFC v4 net-next 03/26] bpf: introduce syscall(BPF, ...)
 and BPF maps
Date: Thu, 14 Aug 2014 15:28:35 -0700
Message-ID: <CAE40pdcCqu6zBqDgAXBpKHzX=y7hXtz83yEadYTE2yACiqyT3g@mail.gmail.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
	<1407916658-8731-4-git-send-email-ast@plumgrid.com>
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
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1407916658-8731-4-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 13, 2014 at 12:57 AM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
[...]
> maps can have different types: hash, bloom filter, radix-tree, etc.
>
> The map is defined by:
>   . type
>   . max number of elements
>   . key size in bytes
>   . value size in bytes

Can values be strings or byte arrays? How would user-level bpf read
them? The two types of uses I'm thinking are:

A. Constructing a custom string in kernel-context, and using that as
the value. Eg, a truncated filename, or a dotted quad IP address, or
the raw contents of a packet.
B. I have a pointer to an existing buffer or string, eg a filename,
that will likely be around for some time (>1s). Instead of the value
storing the string, it could just be a ptr, so long as user-level bpf
has a way to read it.

Also, can keys be strings? I'd ask about multiple keys, but if they
can be a string, I can delimit in the key (eg, "PID:filename").
Thanks,

Brendan

-- 
http://www.brendangregg.com
