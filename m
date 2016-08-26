From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFCv2 07/16] bpf: enable non-core use of the verfier
Date: Fri, 26 Aug 2016 16:29:05 -0700
Message-ID: <20160826232904.GA28873@ast-mbp.thefacebook.com>
References: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com>
 <1472234775-29453-8-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net,
        dinan.gunawardena@netronome.com, jiri@resnulli.us,
        john.fastabend@gmail.com, kubakici@wp.pl
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34318 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752161AbcHZX3K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 19:29:10 -0400
Received: by mail-pf0-f174.google.com with SMTP id p64so32860444pfb.1
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 16:29:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1472234775-29453-8-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 26, 2016 at 07:06:06PM +0100, Jakub Kicinski wrote:
> Advanced JIT compilers and translators may want to use
> eBPF verifier as a base for parsers or to perform custom
> checks and validations.
> 
> Add ability for external users to invoke the verifier
> and provide callbacks to be invoked for every intruction
> checked.  For now only add most basic callback for
> per-instruction pre-interpretation checks is added.  More
> advanced users may also like to have per-instruction post
> callback and state comparison callback.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

I like the apporach. Making verifier into 'bytecode parser'
that JITs can reuse is a good design choice.
The only thing I would suggest is to tweak the verifier to
avoid in-place state recording. Then I think patch 8 for
clone/unclone of the program won't be needed, since verifier
will be read-only from bytecode point of view and patch 9
also will be slightly cleaner.
I think there are very few places in verifier that do this
state keeping inside insn. It was bugging me for some time.
Good time to clean that up.
Unless I misunderstand the patches 7,8,9...

There is also small concern for patches 5 and 6 that add
more register state information. Potentially that extra
state can prevent states_equal() to recognize equivalent
states. Only patch 9 uses that info, right?
Another question is do you need all state walking that
verifier does or single linear pass through insns
would have worked?
Looks like you're only using CONST_IMM and PTR_TO_CTX
state, right?

The rest looks very good. Thanks a lot!
