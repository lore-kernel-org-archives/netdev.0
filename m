From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] tracing: bpf: Hide bpf trace events when they are not
 used
Date: Thu, 12 Oct 2017 18:38:36 -0700
Message-ID: <20171013013834.pxh3ancgutrm6m7t@ast-mbp>
References: <20171012184002.0661a867@gandalf.local.home>
 <20171013011450.w2uqygdfzwf7ud64@ast-mbp>
 <20171012213501.17fe6f8c@vmware.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:54771 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753513AbdJMBij (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 21:38:39 -0400
Content-Disposition: inline
In-Reply-To: <20171012213501.17fe6f8c@vmware.local.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 12, 2017 at 09:35:01PM -0400, Steven Rostedt wrote:
> On Thu, 12 Oct 2017 18:14:52 -0700
> Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
> 
> > On Thu, Oct 12, 2017 at 06:40:02PM -0400, Steven Rostedt wrote:
> > > From: Steven Rostedt (VMware) <rostedt@goodmis.org>
> > > 
> > > All the trace events defined in include/trace/events/bpf.h are only
> > > used when CONFIG_BPF_SYSCALL is defined. But this file gets included by
> > > include/linux/bpf_trace.h which is included by the networking code with
> > > CREATE_TRACE_POINTS defined.
> > > 
> > > If a trace event is created but not used it still has data structures
> > > and functions created for its use, even though nothing is using them.
> > > To not waste space, do not define the BPF trace events in bpf.h unless
> > > CONFIG_BPF_SYSCALL is defined.
> > > 
> > > Signed-off-by: Steven Rostedt (VMware) <rostedt@goodmis.org>  
> > 
> > Looks fine.
> > Acked-by: Alexei Starovoitov <ast@kernel.org>
> > 
> > I'm assuming you want to take it through tracing tree along
> > with all other cleanups?
> 
> Either way is fine. I have a few other ones. I believe Paul is taking
> the RCU patch. There's no dependency.
> 
> I'll take it if it is easier for you. I just need the ack.

actually just noticed that xdp tracepoints are not covered by ifdef.
They depend on bpf_syscall too. So probably makes sense to wrap
them together.
bpf tracepoints are not being actively worked on whereas xdp tracepoints
keep evolving quickly, so the best is probalby to go via net-next
if you don't mind.
