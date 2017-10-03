From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next v2 3/3] tools: bpftool: add documentation
Date: Mon, 2 Oct 2017 18:35:09 -0700
Message-ID: <20171002183509.76b2cc65@cakuba>
References: <20171002231130.12406-1-jakub.kicinski@netronome.com>
        <20171002231130.12406-4-jakub.kicinski@netronome.com>
        <20171003005500.yh2gbnofm5ckn54x@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        oss-drivers@netronome.com,
        David Beckett <david.beckett@netronome.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f176.google.com ([209.85.216.176]:49016 "EHLO
        mail-qt0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750846AbdJCBfO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 21:35:14 -0400
Received: by mail-qt0-f176.google.com with SMTP id d13so9714296qta.5
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 18:35:14 -0700 (PDT)
In-Reply-To: <20171003005500.yh2gbnofm5ckn54x@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2 Oct 2017 17:55:02 -0700, Alexei Starovoitov wrote:
> > +EXAMPLES
> > +========
> > +**# bpftool prog show**
> > +::
> > +
> > +  10: xdp  name:some_prog  tag 00:5a:3d:21:23:62:0c:8b  
> 
> could you please remove ':' in the output to match what
> show_fdinfo and kallsyms do ?

Ack.

> > +	loaded_at:2024.771  uid:0  
> 
> may be translate that to something human readable?

Oh yes, the code will print a proper date/time, I forgot to
regenerate the doc :S

> > +	xlated:528B  jited:370B  memlock:4096B  map_ids:10
> > +
> > +| 
> > +| **# bpftool prog dump xlated id 10 file /tmp/t**
> > +| **# ls -l /tmp/t**
> > +|   -rw------- 1 root root 560 Jul 22 01:42 /tmp/t
> > +
> > +| 
> > +| **# mount -t bpf none /sys/fs/bpf/**
> > +| **# bpftool prog pin id 10 /sys/fs/bpf/prog**
> > +| **# bpftool prog dum jited pinned /sys/fs/bpf/prog**
> > +
> > +::
> > +
> > +    push   %rbp
> > +    mov    %rsp,%rbp
> > +    sub    $0x228,%rsp
> > +    sub    $0x28,%rbp
> > +    mov    %rbx,0x0(%rbp)  
> 
> imo too many steps to dump disasm output.
> Can it print it if we just say:
> bpftool prog dump jited id 10
> and
> dump xlated

Yes those will work.  This example kind of shows pinning and dumping at
the some time.  Perhaps that's ill advised.

> will pretty print them as verifier output as well?

We tried to use LLVM as a library for this but the interface is
painfully unstable and it's a heavy dependency.  The current thinking
is to try to put the instruction printing code in some higher level
library, but I would rather leave that as a follow up.

> All that can be changed later. Thanks for the doc.
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Thanks!
