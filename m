From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [RFCv2 07/16] bpf: enable non-core use of the verfier
Date: Tue, 30 Aug 2016 22:22:46 +0200
Message-ID: <20160830222246.29e3f3cc@laptop>
References: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com>
        <1472234775-29453-8-git-send-email-jakub.kicinski@netronome.com>
        <20160826232904.GA28873@ast-mbp.thefacebook.com>
        <20160827124004.43728202@jkicinski-Precision-T1700>
        <20160827173250.GA38477@ast-mbp>
        <57C4976C.4010501@iogearbox.net>
        <57C49846.1080608@iogearbox.net>
        <20160830124854.76e5a1c3@laptop>
        <57C5D986.2000402@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org, ast@kernel.org,
        dinan.gunawardena@netronome.com, jiri@resnulli.us,
        john.fastabend@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.10]:35492 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751118AbcH3UWv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 Aug 2016 16:22:51 -0400
In-Reply-To: <57C5D986.2000402@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Aug 2016 21:07:50 +0200, Daniel Borkmann wrote:
> > Having two modes seems more straight forward and I think we would only
> > need to pay attention in the LD_IMM64 case, I don't think I've seen
> > LLVM generating XORs, it's just the cBPF -> eBPF conversion.  
> 
> Okay, though, I think that the cBPF to eBPF migration wouldn't even
> pass through the bpf_parse() handling, since verifier is not aware on
> some of their aspects such as emitting calls directly (w/o *proto) or
> arg mappings. Probably make sense to reject these (bpf_prog_was_classic())
> if they cannot be handled anyway?

TBH again I only use cBPF for testing.  It's a convenient way of
generating certain instruction sequences.  I can probably just drop
it completely but the XOR patch is just 3 lines of code so not a huge
cost either...  I'll keep patch 6 in my tree for now.  

Alternatively - is there any eBPF assembler out there?  Something
converting verifier output back into ELF would be quite cool.
