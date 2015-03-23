From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v9 tip 6/9] samples: bpf: simple non-portable kprobe filter
 example
Date: Mon, 23 Mar 2015 10:23:04 -0700
Message-ID: <55104BF8.8000606@plumgrid.com>
References: <1426894210-27441-1-git-send-email-ast@plumgrid.com> <1426894210-27441-7-git-send-email-ast@plumgrid.com> <20150323072929.GB25184@gmail.com>
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
In-Reply-To: <20150323072929.GB25184-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 3/23/15 12:29 AM, Ingo Molnar wrote:
>
>> **                                                      **
>> ** This means that this is a DEBUG kernel and it is     **
>> ** unsafe for production use.                           **
>
> But I think printing that it's unsafe for production use is over the
> top: it's up to the admin whether it's safe or unsafe, just like
> inserting a kprobe can be safe or unsafe.
>
> Informing that something happened is enough.

Well that is Steven's banner and I agree that it's a bit extreme.
I think it's done on purpose to scary people away from using
trace_printk() for anything other than debug.
It applies to both native trace_printk() for kernel debugging and
for bpf_trace_printk() for debugging of bpf programs.
I don't have a strong opinion about native case, but for bpf I do want
this banner to be scary. Otherwise it's too easy to start using
bpf_trace_printk() to pass event notifications to user space.
bpf_trace_printk and trace_pipe parsing shouldn't be used as a way
to communicate between programs and user space.
At the end, in actual production use, bpf programs won't be using it
and no banner will be seen.
Anyway, I don't think I can change this banner in this patch set.
If we decide to relax it, it should be done via Steven's tree.
