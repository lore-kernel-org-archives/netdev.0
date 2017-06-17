From: Shubham Bansal <illusionist.neo@gmail.com>
Subject: Re: [PATCH v2] arm: eBPF JIT compiler
Date: Sat, 17 Jun 2017 17:53:07 +0530
Message-ID: <CAHgaXdKMbFPgy-kKF0iDSAYo4CqLn9FRu9HwM+OfM-JWb9fNRQ@mail.gmail.com>
References: <1495754003-21099-1-git-send-email-illusionist.neo@gmail.com>
 <CAGXu5jKmLNMR+uhM9Ov2XPW6kCjip_SjScgEH0fTFp6fQtKFiA@mail.gmail.com>
 <593E6B0F.8070901@iogearbox.net> <CAHgaXd+DW2bggto=2S9hOdMrtPTvhD2QN4rPf2V8iHewQpg-YA@mail.gmail.com>
 <CAHgaXdJrvKdzr3fJ1TMkC4foeVsZJDSVEwhDOeZGxQVsmoK2cQ@mail.gmail.com> <59419D1E.2060303@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Kees Cook <keescook@chromium.org>,
        Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Russell King <linux@armlinux.org.uk>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        LKML <linux-kernel@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <59419D1E.2060303@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Daniel,

>
> Not all of the helpers have 4 or less byte arguments only, there are a
> few with 8 byte arguments, so making that general assumption wouldn't
> work. I guess what could be done is that helpers have a flag in struct
> bpf_func_proto which indicates for JITs that all args are 4 byte on 32bit
> so you could probably use convention similar to case2 for them. Presumably
> for that information to process, the JIT might need to be reworked to
> extract that via bpf_analyzer() that does a verifier run to re-analyze
> the program like in nfp JIT case.

Let me try a better solution which can be used to support both 4 byte
and 8 byte arguments. I hope it would work out. Are you sure this
patch can pass if it only supports 4 byte arguments though?
Let me list out what I have to do, so that you can tell me if I am
thinking in a wrong way :-

* I will add a bit flag in bpf_func_proto to represent whether
different arguments in a function call are 4 bytes or 8 bytes. If lsb
of bit flag is set then first argument is 8 byte, otherwise its not. I
think I can handle this flag properly in build_insn() in my code. Does
this sound okay?

I don't understand second part of your solution, i.e.

> Presumably
> for that information to process, the JIT might need to be reworked to
> extract that via bpf_analyzer() that does a verifier run to re-analyze
> the program like in nfp JIT case.

Please explain what are you suggesting and how can I extract bit flag
from bpf_func_proto().

Please reply asap, as I would like to finish it over the weekend. Please.

-Shubham
