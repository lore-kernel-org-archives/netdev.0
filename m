From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] tracing: bpf: Hide bpf trace events when they are not
 used
Date: Thu, 12 Oct 2017 21:49:45 -0400
Message-ID: <20171012214945.1fbcba2f@vmware.local.home>
References: <20171012184002.0661a867@gandalf.local.home>
        <20171013011450.w2uqygdfzwf7ud64@ast-mbp>
        <20171012213501.17fe6f8c@vmware.local.home>
        <20171013013834.pxh3ancgutrm6m7t@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171013013834.pxh3ancgutrm6m7t@ast-mbp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 12 Oct 2017 18:38:36 -0700
Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> actually just noticed that xdp tracepoints are not covered by ifdef.
> They depend on bpf_syscall too. So probably makes sense to wrap
> them together.
> bpf tracepoints are not being actively worked on whereas xdp tracepoints
> keep evolving quickly, so the best is probalby to go via net-next
> if you don't mind.

Hmm, they didn't trigger a warning, with the exception of
trace_xdp_redirect_map. I have code to check if tracepoints are used or
not, and it appears that the xdp can be used without BPF_SYSCALL.

I don't think they should be wrapped together until we know why they
are used. I can still take this patch and just not touch the xdp ones.

Note, my kernel was using trace_xdp_redirect_map_err,
trace_xdp_redirect_err, trace_xdp_redirect and trace_xdp_exception.

As they did appear.

-- Steve
