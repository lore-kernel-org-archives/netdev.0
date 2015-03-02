From: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Subject: Re: [PATCH v5 tip 1/7] bpf: make internal bpf API independent of
 CONFIG_BPF_SYSCALL ifdefs
Date: Mon, 02 Mar 2015 12:10:19 +0100
Message-ID: <54F4451B.8000703@iogearbox.net>
References: <1425252465-27527-1-git-send-email-ast@plumgrid.com> <1425252465-27527-2-git-send-email-ast@plumgrid.com> <54F44115.40505@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54F44115.40505-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/02/2015 11:53 AM, Masami Hiramatsu wrote:
...
> Hmm, it seems that this still doesn't hide some APIs which is provided
> only when CONFIG_BPF_SYSCALL. For example bpf_register_map_type etc.
> I think all those APIs should be hidden in #ifdef or at least be commented
> so that the user doesn't refer that without the kconfig.
> (I don't think we need to provide dummy functions for those APIs,
>   but it's better to clarify which API we can use with which kconfig)

Well, currently all possible map types (hash table, array map) that
would actually call into bpf_register_map_type() are only built when
CONFIG_BPF_SYSCALL is enabled (see kernel/bpf/Makefile). I don't think
new map additions should be added that are not under kernel/bpf/ and/or
enabled outside the CONFIG_BPF_SYSCALL, as it should be considered
part of the eBPF core code.

The difference here (this patch) is simply that we don't want users to
build ifdef spaghetti constructs in user code, so the API that is
actually used by eBPF _users_ is being properly ifdef'ed in the headers.

So, I don't think this is a big problem, but we could move these bits
under the ifdef CONFIG_BPF_SYSCALL w/o providing a dummy in the else part.
I can do that outside of the scope of this set.
