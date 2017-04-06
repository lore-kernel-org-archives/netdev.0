From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC net-next] bpf: taint loading !is_gpl programs
Date: Thu, 6 Apr 2017 08:41:01 -0400
Message-ID: <20170406124059.GB53880@ast-mbp.thefacebook.com>
References: <20170404183354.8579-1-aconole@bytheb.org>
 <58E40C2B.7040802@iogearbox.net>
 <f7tpogqmeai.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Aaron Conole <aconole@bytheb.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:36601 "EHLO
        mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754772AbdDFMlF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 08:41:05 -0400
Content-Disposition: inline
In-Reply-To: <f7tpogqmeai.fsf@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 05, 2017 at 10:59:49PM -0400, Aaron Conole wrote:
> Hi Daniel,
> 
> Daniel Borkmann <daniel@iogearbox.net> writes:
> 
> > On 04/04/2017 08:33 PM, Aaron Conole wrote:
> >> The eBPF framework is used for more than just socket level filtering.  It
> >> can also provide tracing, and even change the way packets coming into the
> >> system look.  Most of the eBPF callable symbols are available to non-gpl
> >> programs, and this includes helper functions which modify packets.  This
> >> allows proprietary eBPF code to link to the kernel and make decisions
> >> which can negatively impact network performance.
> >>
> >> Since the sources for these programs are only available under a proprietary
> >> license, it seems better to treat them the same as other proprietary
> >> modules: set the system taint flag.  An exemption is made for socket-level
> >> filters, since they do not really impact networking for the whole kernel.
> >>
> >> Signed-off-by: Aaron Conole <aconole@bytheb.org>
> >> ---
> >
> > Nacked-by: Daniel Borkmann <daniel@iogearbox.net>
> 
> Thanks so much for looking at the patch!

Passive aggressive way of saying 'I want to waste your time'. Not cool.

> > This is proposal completely unreasonable; what the purpose of .gpl_only
> > flags is agreed upon since the beginning is that some of the helpers
> > are only available if the program is loaded as gpl, f.e. bpf_ktime_get_ns(),
> > bpf_probe_read(), bpf_probe_write_user(), bpf_trace_printk(),
> > bpf_skb_event_output(), etc.
> 
> This behavior isn't changing with this patch.

It's breaking userspace, hence obvious Nack.

> all of the networking functions, are gpl_only = false.  This means the
> community will have a difficult time supporting reports from this
> system.  After all, there's no way to know exactly how this eBPF program
> has changed packets in the network without a license to the code.

bpf is the user space program. Whatever you mean by 'community'
is obviously cannot 'support' all possible user space applications
written using given kernel abi.
The reason tracing progs are gpl because they look into gpl-ed kernel,
networking progs don't. They deal with bytes on the wire.
