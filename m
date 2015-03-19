From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v7 tip 3/8] tracing: allow BPF programs to call bpf_ktime_get_ns()
Date: Thu, 19 Mar 2015 08:38:05 -0700
Message-ID: <550AED5D.3010700@plumgrid.com>
References: <1426542584-9406-1-git-send-email-ast@plumgrid.com>	<1426542584-9406-4-git-send-email-ast@plumgrid.com> <20150319111124.38f53061@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150319111124.38f53061-f9ZlEuEWxVcJvu8Pb33WZ0EMvNT87kid@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 3/19/15 8:11 AM, Steven Rostedt wrote:
> On Mon, 16 Mar 2015 14:49:39 -0700
> Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>
>> bpf_ktime_get_ns() is used by programs to compue time delta between events
>
>   "compute"

ok :)

>> +	[BPF_FUNC_ktime_get_ns] = {
>> +		.func = bpf_ktime_get_ns,
>> +		.gpl_only = true,
>> +		.ret_type = RET_INTEGER,
>
> Hmm, a nanosecond value returned as integer? Is there a way to make
> this a 64 bit return type, or is RET_INTEGER default to 64 bits in BPF
> functions?

RET_INTEGER doesn't mean C 'int' width. It means non-pointer and
non-void value. The return value is always promoted to full
register width which is 64-bit.
