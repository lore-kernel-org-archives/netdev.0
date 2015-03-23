From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v9 tip 6/9] samples: bpf: simple non-portable kprobe filter
 example
Date: Mon, 23 Mar 2015 10:32:45 -0700
Message-ID: <55104E3D.20103@plumgrid.com>
References: <1426894210-27441-1-git-send-email-ast@plumgrid.com> <1426894210-27441-7-git-send-email-ast@plumgrid.com> <20150323073506.GC25184@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150323073506.GC25184-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 3/23/15 12:35 AM, Ingo Molnar wrote:
>
> * Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>
>> +void read_trace_pipe(void)
>> +{
>> +	int trace_fd;
>> +
>> +	trace_fd = open(DEBUGFS "trace_pipe", O_RDONLY, 0);
>> +	if (trace_fd < 0)
>> +		return;
>> +
>> +	while (1) {
>> +		static char buf[4096];
>> +		ssize_t sz;
>> +
>> +		sz = read(trace_fd, buf, sizeof(buf));
>
> read() will return -1 on failure ...
>
>> +		if (sz) {
>
> ... this test passes ...
>
>> +			buf[sz] = 0;
>
> ... and here we smash the stack?

good point. If it was normal file, for sure it's a bug, but trace_pipe
is a pseudo file and I think read cannot return -1. Regardless, it makes
sense to fix it. Will do. Do you mind I address it as follow up patch?
Or if the rest is ok, can you change the condition to sz>0 while
applying? I can respin the whole thing too, if you like.
Thanks!
