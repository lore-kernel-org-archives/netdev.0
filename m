From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH RFC 2/3] kcm: Kernel Connection Multiplexor module
Date: Tue, 22 Sep 2015 11:41:48 -0700
Message-ID: <20150922184147.GA15552@Alexeis-MBP-2.westell.com>
References: <1442788161-2626305-1-git-send-email-tom@herbertland.com>
 <1442788161-2626305-3-git-send-email-tom@herbertland.com>
 <20150922162618.GA15483@Alexeis-MBP-2.westell.com>
 <CALx6S36H1YL1w4mS4Ee6TSV3nce0J4GT_e7+2h1b=o2nT+0ZUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alex Gartrell <agartrell@fb.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34723 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934159AbbIVSlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 14:41:52 -0400
Received: by padhy16 with SMTP id hy16so16529162pad.1
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 11:41:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S36H1YL1w4mS4Ee6TSV3nce0J4GT_e7+2h1b=o2nT+0ZUw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 22, 2015 at 10:26:10AM -0700, Tom Herbert wrote:
> > I would only suggest to drop support for classic BPF.
> > It's usable to return frame length of http2, but it won't be
> > able to parse protocols where fields are little endian.
> > Also it doesn't scale, since new cBPF program would be created
> > for every KCM socket, whereas with eBPF we can use single program
> > for all KCM sockets via single FD.
> >
> Hi Alexei,
> 
> That makes sense, but I think there may be some use cases where we'd
> like lightweight methods to program filters. Writing C code for BPF is
> extremely cool, but integrating LLVM/Clang into our development
> environment may be a pain. We also might want to create a different
> program for every socket anyway (like from some template with
> parameterization). An eBPF assembler and jit support could be useful
> (looks like there might be some work started on both of these
> already).

coding eBPF with macros as sock_example.c, test_verifier.c,
test_bpf.c do should be enough to start. User space assembler
to convert text to eBPF binary obviously would be even better.
But lack of tiny and standalone assembler today shouldn't be
the reason to include classic as permenent kernel ABI.
Not sure what you mean by 'jit support'. There is in-kernel jit
and there is jit mode of llvm where bpf can be taken from
memory without going to elf file.
