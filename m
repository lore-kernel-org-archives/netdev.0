From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v3] tracing/kprobes: expose maxactive for kretprobe in
 kprobe_events
Date: Tue, 4 Apr 2017 10:32:53 -0400
Message-ID: <20170404103253.11d03dc1@gandalf.local.home>
References: <1491215782-15490-1-git-send-email-alban@kinvolk.io>
        <20170404202459.6ca0e044df141602fe7033f9@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alban Crequy <alban.crequy@gmail.com>,
        Alban Crequy <alban@kinvolk.io>,
        Alexei Starovoitov <ast@kernel.org>,
        Jonathan Corbet <corbet@lwn.net>,
        Ingo Molnar <mingo@redhat.com>, Shuah Khan <shuah@kernel.org>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Omar Sandoval <osandov@fb.com>,
        Anton Blanchard <anton@samba.org>, linux-doc@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-kselftest@vger.kernel.org, iago@kinvolk.io,
        michael@kinvolk.io, lukasz.dorau@intel.com,
        vitalii.chernookyi@intel.com, marcin.slusarz@intel.com,
        sarah.jelinek@intel.com, gabor.buella@intel.com
To: Masami Hiramatsu <mhiramat@kernel.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20170404202459.6ca0e044df141602fe7033f9@kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 4 Apr 2017 20:24:59 +0900
Masami Hiramatsu <mhiramat@kernel.org> wrote:

> On Mon,  3 Apr 2017 12:36:22 +0200
> Alban Crequy <alban.crequy@gmail.com> wrote:
> 
> > From: Alban Crequy <alban@kinvolk.io>
> > 
> > When a kretprobe is installed on a kernel function, there is a maximum
> > limit of how many calls in parallel it can catch (aka "maxactive"). A
> > kernel module could call register_kretprobe() and initialize maxactive
> > (see example in samples/kprobes/kretprobe_example.c).
> > 
> > But that is not exposed to userspace and it is currently not possible to
> > choose maxactive when writing to /sys/kernel/debug/tracing/kprobe_events
> > 
> > The default maxactive can be as low as 1 on single-core with a
> > non-preemptive kernel. This is too low and we need to increase it not
> > only for recursive functions, but for functions that sleep or resched.
> > 
> > This patch updates the format of the command that can be written to
> > kprobe_events so that maxactive can be optionally specified.
> > 
> > I need this for a bpf program attached to the kretprobe of
> > inet_csk_accept, which can sleep for a long time.
> > 
> > This patch includes a basic selftest:
> >   
> > > # ./ftracetest -v  test.d/kprobe/
> > > === Ftrace unit tests ===
> > > [1] Kprobe dynamic event - adding and removing	[PASS]
> > > [2] Kprobe dynamic event - busy event check	[PASS]
> > > [3] Kprobe dynamic event with arguments	[PASS]
> > > [4] Kprobes event arguments with types	[PASS]
> > > [5] Kprobe dynamic event with function tracer	[PASS]
> > > [6] Kretprobe dynamic event with arguments	[PASS]
> > > [7] Kretprobe dynamic event with maxactive	[PASS]
> > >
> > > # of passed:  7
> > > # of failed:  0
> > > # of unresolved:  0
> > > # of untested:  0
> > > # of unsupported:  0
> > > # of xfailed:  0
> > > # of undefined(test bug):  0  
> > 
> > BugLink: https://github.com/iovisor/bcc/issues/1072
> > Signed-off-by: Alban Crequy <alban@kinvolk.io>  
> 
> Looks good to me.
> 
> Acked-by: Masami Hiramatsu <mhiramat@kernel.org>
> 

Applied, thanks!

-- Steve
