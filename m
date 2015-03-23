From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v10 tip 5/9] tracing: allow BPF programs to call bpf_trace_printk()
Date: Mon, 23 Mar 2015 10:50:09 -0700
Message-ID: <55105251.6070807@plumgrid.com>
References: <1427053150-32213-1-git-send-email-ast@plumgrid.com> <1427053150-32213-6-git-send-email-ast@plumgrid.com> <063D6719AE5E284EB5DD2968C1650D6D1CB07731@AcuExch.aculab.com> <20150323120753.GA22560@gmail.com>
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
	"linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150323120753.GA22560-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 3/23/15 5:07 AM, Ingo Molnar wrote:
>
> * David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org> wrote:
>
>> From: Alexei Starovoitov
>>> Debugging of BPF programs needs some form of printk from the program,
>>> so let programs call limited trace_printk() with %d %u %x %p modifiers only.
>>
>> Should anyone be allowed to use BPF programs to determine the kernel
>> addresses of any items?
>> Looks as though it is leaking kernel addresses to userspace.
>> Note that the problem is with the arguments, not the format string.
>
> All of these are privileged operations - inherent if you are trying to
> debug the kernel.

yep.

There is a plan to add 'pointer leak detector' to bpf verifier and
'constant blinding' pass, so in the future we may let unprivileged
users load programs. seccomp will be first such user. But it will
take long time.
