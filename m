From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v11 tip 6/9] samples: bpf: simple non-portable kprobe
 filter example
Date: Sun, 29 Mar 2015 17:59:54 -0700
Message-ID: <5518A00A.5090004@plumgrid.com>
References: <1427312966-8434-1-git-send-email-ast@plumgrid.com>	<1427312966-8434-7-git-send-email-ast@plumgrid.com> <CAGdX0WESZ8kb7R3U38ciJambE_qBPnf3MiKiKa2wR-50H6_NyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jovi Zhangwei <jovi.zhangwei-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGdX0WESZ8kb7R3U38ciJambE_qBPnf3MiKiKa2wR-50H6_NyQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 3/29/15 5:34 PM, Jovi Zhangwei wrote:
>> +               snprintf(buf, sizeof(buf),
>> +                        "echo '%c:%s %s' >> /sys/kernel/debug/tracing/kprobe_events",
>> +                        is_kprobe ? 'p' : 'r', event, event);
>> +               err = system(buf);
>
> Maybe we need to remember cleanup the kprobe_events in debugfs?

the real tracing tool should be cleaning it up. This is sample code.
I didn't want to overcomplicate it with a chain of ctrl-c handlers.
Notice patch 7 is simply doing signal(SIGINT, int_exit) and prints
histogram when process is terminated. The kprobe cleaning logic would
have interfere with this and overall would have made these samples
unnecessary complex.
