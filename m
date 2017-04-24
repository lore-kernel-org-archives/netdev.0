From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: [PATCH v3 07/29] x86: bpf_jit, use ENTRY+ENDPROC
Date: Mon, 24 Apr 2017 16:52:43 +0200
Message-ID: <f7a94f4e-6d93-a447-a62f-3f290e66c647@suse.cz>
References: <20170421141305.25180-7-jslaby@suse.cz>
 <20170421193213.GB91454@ast-mbp.thefacebook.com>
 <697947f4-0a2c-1480-0995-9919556dc020@suse.cz>
 <20170424.104132.950580313142367896.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, mingo@redhat.com, tglx@linutronix.de,
        hpa@zytor.com, x86@kernel.org, jpoimboe@redhat.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        daniel@iogearbox.net, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170424.104132.950580313142367896.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/24/2017, 04:41 PM, David Miller wrote:
>> It cannot stay as-is simply because we want to know where the functions
>> end to inject debuginfo properly. The code above does not warrant for
>> any exception.
> 
> I totally and completely disagree.

You can disagree as you wish but there is really nothing special on the
bpf code with respect to annotations.

>> Executing a nop takes a little and having externally-callable functions
>> aligned can actually help performance (no, I haven't measured nor tested
>> the code). But sure, the tool is generic, so I can introduce a local
>> macros to avoid alignments in the functions:
> 
> Not for this case, it's a bunch of entry points all packed together
> intentionally so that SKB accesses of different access sizes (which is
> almost always the case) from BPF programs use the smallest amount of
> I-cache as possible.

And for that reason I suggested the special macros for the code (see the
macros in the e-mail you replied to again). So what problem do you
actually have with the suggested solution?

thanks,
-- 
js
suse labs
