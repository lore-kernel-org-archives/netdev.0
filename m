From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 07/29] x86: bpf_jit, use ENTRY+ENDPROC
Date: Mon, 24 Apr 2017 11:51:18 -0400 (EDT)
Message-ID: <20170424.115118.1652158849030310645.davem@davemloft.net>
References: <f7a94f4e-6d93-a447-a62f-3f290e66c647@suse.cz>
        <20170424.110844.1321374394090353753.davem@davemloft.net>
        <614ca52b-8a43-244e-8a3a-c39145ecc3e8@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, mingo@redhat.com, tglx@linutronix.de,
        hpa@zytor.com, x86@kernel.org, jpoimboe@redhat.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        daniel@iogearbox.net, edumazet@google.com
To: jslaby@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51846 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S972078AbdDXPvV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 11:51:21 -0400
In-Reply-To: <614ca52b-8a43-244e-8a3a-c39145ecc3e8@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Slaby <jslaby@suse.cz>
Date: Mon, 24 Apr 2017 17:41:06 +0200

> On 04/24/2017, 05:08 PM, David Miller wrote:
>> If you align the entry points, then the code sequence as a whole is
>> are no longer densely packed.
> 
> Sure.
> 
>> Or do I misunderstand how your macros work?
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

I said I'm not OK with the alignment, so personally I am not
with how these macros work and what they will do to the code
generated for BPF packet accesses.

But I'll defer to Alexei on this because I don't have the time
nor the energy to fight this.

Thanks.
