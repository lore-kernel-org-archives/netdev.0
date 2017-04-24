From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v3 07/29] x86: bpf_jit, use ENTRY+ENDPROC
Date: Mon, 24 Apr 2017 17:55:07 +0200
Message-ID: <20170424155507.miyqef7ld4hbmsej@gmail.com>
References: <697947f4-0a2c-1480-0995-9919556dc020@suse.cz>
 <20170424.104132.950580313142367896.davem@davemloft.net>
 <f7a94f4e-6d93-a447-a62f-3f290e66c647@suse.cz>
 <20170424.110844.1321374394090353753.davem@davemloft.net>
 <614ca52b-8a43-244e-8a3a-c39145ecc3e8@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, alexei.starovoitov@gmail.com,
        mingo@redhat.com, tglx@linutronix.de, hpa@zytor.com,
        x86@kernel.org, jpoimboe@redhat.com, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, daniel@iogearbox.net, edumazet@google.com
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:36835 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S971996AbdDXPzL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 11:55:11 -0400
Content-Disposition: inline
In-Reply-To: <614ca52b-8a43-244e-8a3a-c39145ecc3e8@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Jiri Slaby <jslaby@suse.cz> wrote:

> On 04/24/2017, 05:08 PM, David Miller wrote:
> > If you align the entry points, then the code sequence as a whole is
> > are no longer densely packed.
> 
> Sure.
> 
> > Or do I misunderstand how your macros work?
> 
> Perhaps. So the suggested macros for the code are:
> #define BPF_FUNC_START_LOCAL(name) \
> 		SYM_START(name, SYM_V_LOCAL, SYM_A_NONE)
> #define BPF_FUNC_START(name) \
> 		SYM_START(name, SYM_V_GLOBAL, SYM_A_NONE)
> 
> and they differ from the standard ones:
> #define SYM_FUNC_START_LOCAL(name)                      \
>         SYM_START(name, SYM_V_LOCAL, SYM_A_ALIGN)
> #define SYM_FUNC_START(name)                            \
>         SYM_START(name, SYM_V_GLOBAL, SYM_A_ALIGN)
> 
> 
> The difference is SYM_A_NONE vs. SYM_A_ALIGN, which means:
> #define SYM_A_ALIGN                             ALIGN
> #define SYM_A_NONE                              /* nothing */
> 
> Does it look OK now?

No, the patch changes alignment which is undesirable, it needs to preserve the 
existing (non-)alignment of the symbols!

Thanks,

	Ingo
