From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC PATCH tip/master 2/3] kprobes: Allocate kretprobe instance if its free list is empty
Date: Wed, 12 Apr 2017 08:42:26 +0200
Message-ID: <20170412064226.GA7737@gmail.com>
References: <149076484118.24574.7083269903420611708.stgit@devbox> <149076498222.24574.679546540523044200.stgit@devbox> <20170329063005.GA12220@gmail.com> <20170329172510.e012406497fd38a54d5069b3@kernel.org> <20170330065332.GA30148@gmail.com> <20170330220134.448b65b9102edcf8ba1a2c81@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>,	Alban Crequy <alban.crequy@gmail.com>,	Alban Crequy <alban@kinvolk.io>,	Alexei Starovoitov <ast@kernel.org>,	Jonathan Corbet <corbet@lwn.net>,	Arnaldo Carvalho de Melo <acme@redhat.com>,	Omar Sandoval <osandov@fb.com>, linux-doc@vger.kernel.org,	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,	iago@kinvolk.io, michael@kinvolk.io,	Dorau Lukasz <lukasz.dorau@intel.com>, systemtap@sourceware.org
To: Masami Hiramatsu <mhiramat@kernel.org>
Return-path: <systemtap-return-25277-gls-systemtap=m.gmane.org@sourceware.org>
List-Unsubscribe: <mailto:systemtap-unsubscribe-gls-systemtap=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:systemtap-subscribe@sourceware.org>
List-Post: <mailto:systemtap@sourceware.org>
List-Help: <mailto:systemtap-help@sourceware.org>, <http://sourceware.org/lists.html#faqs>
Sender: systemtap-owner@sourceware.org
Content-Disposition: inline
In-Reply-To: <20170330220134.448b65b9102edcf8ba1a2c81@kernel.org>
List-Id: netdev.vger.kernel.org


* Masami Hiramatsu <mhiramat@kernel.org> wrote:

> On Thu, 30 Mar 2017 08:53:32 +0200
> Ingo Molnar <mingo@kernel.org> wrote:
> 
> > 
> > * Masami Hiramatsu <mhiramat@kernel.org> wrote:
> > 
> > > > So this is something I missed while the original code was merged, but the concept 
> > > > looks a bit weird: why do we do any "allocation" while a handler is executing?
> > > > 
> > > > That's fundamentally fragile. What's the maximum number of parallel 
> > > > 'kretprobe_instance' required per kretprobe - one per CPU?
> > > 
> > > It depends on the place where we put the probe. If the probed function will be
> > > blocked (yield to other tasks), then we need a same number of threads on
> > > the system which can invoke the function. So, ultimately, it is same
> > > as function_graph tracer, we need it for each thread.
> > 
> > So then put it into task_struct (assuming there's no kretprobe-inside-kretprobe 
> > nesting allowed).
> 
> No, that is possible to put several kretprobes on same thread, e.g.
> the func1() is called from func2(), user can put kretprobes for each
> function at same time.
> So the possible solution is to allocate new return-stack for each task_struct,
> and that is what the function-graph tracer did.
> 
> Anyway, I'm considering to integrate kretprobe_instance with the ret_stack.
> It will increase memory usage for kretprobes, but can provide safer way
> to allocate kretprobe_instance.

Ok, that sounds good to me.

Thanks,

	Ingo
