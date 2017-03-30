From: Alban Crequy <alban@kinvolk.io>
Subject: Re: [RFC PATCH tip/master 2/3] kprobes: Allocate kretprobe instance if its free list is empty
Date: Thu, 30 Mar 2017 15:03:11 +0200
Message-ID: <CADZs7q4H4+yUNaOnOR26XYSC1uq_+Dy-DmKN=dwj8vwZcuG4LA@mail.gmail.com>
References: <149076484118.24574.7083269903420611708.stgit@devbox> <149076498222.24574.679546540523044200.stgit@devbox> <20170329063005.GA12220@gmail.com> <20170329172510.e012406497fd38a54d5069b3@kernel.org> <20170330065332.GA30148@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Masami Hiramatsu <mhiramat@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, 	Ingo Molnar <mingo@redhat.com>, Alban Crequy <alban.crequy@gmail.com>, 	Alexei Starovoitov <ast@kernel.org>, Jonathan Corbet <corbet@lwn.net>, 	Arnaldo Carvalho de Melo <acme@redhat.com>, Omar Sandoval <osandov@fb.com>, linux-doc@vger.kernel.org, 	netdev@vger.kernel.org, linux-kernel@vger.kernel.org, 	=?UTF-8?Q?Iago_L=C3=B3pez_Galeiras?= <iago@kinvolk.io>, 	Michael Schubert <michael@kinvolk.io>, Dorau Lukasz <lukasz.dorau@intel.com>, systemtap@sourceware.org
To: Ingo Molnar <mingo@kernel.org>
Return-path: <systemtap-return-25250-gls-systemtap=m.gmane.org@sourceware.org>
List-Unsubscribe: <mailto:systemtap-unsubscribe-gls-systemtap=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:systemtap-subscribe@sourceware.org>
List-Post: <mailto:systemtap@sourceware.org>
List-Help: <mailto:systemtap-help@sourceware.org>, <http://sourceware.org/lists.html#faqs>
Sender: systemtap-owner@sourceware.org
In-Reply-To: <20170330065332.GA30148@gmail.com>
List-Id: netdev.vger.kernel.org

On Thu, Mar 30, 2017 at 8:53 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Masami Hiramatsu <mhiramat@kernel.org> wrote:
>
>> > So this is something I missed while the original code was merged, but the concept
>> > looks a bit weird: why do we do any "allocation" while a handler is executing?
>> >
>> > That's fundamentally fragile. What's the maximum number of parallel
>> > 'kretprobe_instance' required per kretprobe - one per CPU?
>>
>> It depends on the place where we put the probe. If the probed function will be
>> blocked (yield to other tasks), then we need a same number of threads on
>> the system which can invoke the function. So, ultimately, it is same
>> as function_graph tracer, we need it for each thread.
>
> So then put it into task_struct (assuming there's no kretprobe-inside-kretprobe
> nesting allowed). There's just no way in hell we should be calling any complex
> kernel function from kernel probes!

Some kprobes are called from an interruption context. We have a kprobe
on tcp_set_state() and this is sometimes called when the network card
receives a packet.

> I mean, think about it, a kretprobe can be installed in a lot of places, and now
> we want to call get_free_pages() from it?? This would add a massive amount of
> fragility.
>
> Instrumentation must be _simple_, every patch that adds more complexity to the
> most fundamental code path of it should raise a red flag ...
>
> So let's make this more robust, ok?
>
> Thanks,
>
>         Ingo

Thanks,
Alban
