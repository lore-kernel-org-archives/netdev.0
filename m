From: Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH v2 linux-trace 1/8] tracing: attach eBPF programs to tracepoints
 and syscalls
Date: Thu, 29 Jan 2015 14:39:19 +0900
Message-ID: <54C9C787.1040706@hitachi.com>
References: <CAMEtUuz+N52ms4ZFh8+fSGhg1UaXpBdk9RVPU_zBDCjaZ4bj4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMEtUuz+N52ms4ZFh8+fSGhg1UaXpBdk9RVPU_zBDCjaZ4bj4A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

(2015/01/29 13:40), Alexei Starovoitov wrote:
> On Wed, Jan 28, 2015 at 4:46 PM, Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
>>>
>>> +static int event_filter_release(struct inode *inode, struct file *filp)
>>> +{
>>> +     struct ftrace_event_file *file;
>>> +     char buf[2] = "0";
>>> +
>>> +     mutex_lock(&event_mutex);
>>> +     file = event_file_data(filp);
>>> +     if (file) {
>>> +             if (file->flags & TRACE_EVENT_FL_BPF) {
>>> +                     /* auto-disable the filter */
>>> +                     ftrace_event_enable_disable(file, 0);
>>
>> Hmm.. what if user already enabled an event, attached a bpf filter and
>> then detached the filter - I'm not sure we can always auto-disable
>> it..
> 
> why not?
> I think it makes sense auto enable/disable, since that
> is cleaner user experience.

Maybe, would we need a reference counter for each event? :)

Actually, ftrace event is not similar to perf-event which ktap
is based on, ftrace event interface is always exported via
debugfs, this means users can share the event for different
usage.

One possible other solution is to add a instance-lock interface
for each ftrace instance and lock it by bpf. Then, other users
can not enable/disable the events in the instance.

Thank you,


-- 
Masami HIRAMATSU
Software Platform Research Dept. Linux Technology Research Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org
