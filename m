From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v6 tip 3/8] tracing: allow BPF programs to call bpf_ktime_get_ns()
Date: Fri, 13 Mar 2015 09:38:37 -0700
Message-ID: <5503128D.70908@plumgrid.com>
References: <1426047534-8148-1-git-send-email-ast@plumgrid.com> <1426047534-8148-4-git-send-email-ast@plumgrid.com> <5502C8EB.9070307@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
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
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, wangnan0-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: He Kuang <hekuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5502C8EB.9070307-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 3/13/15 4:24 AM, He Kuang wrote:
> Hi, Alexei
>
> I've followed up your bpf version. In bpf filter, sometimes we need to
> get 'pid' and some other context informations to decide whether to
> filter or not.
>
> For example, to trace a vfs read procedure, we can insert bpf program to
> '__vfs_read(struct file *file, char __user *buf ...)', mark some of
> 'buf' addresses and only trace the read procedure of these 'buf's. But
> this parameter is a userspace pointer, the value is meaningless to other
> processes, so we should also record 'pid' to make sense.
>
> To a function like __vfs_read, 'pid' can't be extracted from function
> parameters directly. What's your opinion on this issue?

yes. it's the next thing on todo list after this set of patches.
There are several ways to let programs see 'pid'. We'll debate about
the best approach hopefully soon :)
