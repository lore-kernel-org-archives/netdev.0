From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2] arm: eBPF JIT compiler
Date: Tue, 20 Jun 2017 18:55:03 +0200
Message-ID: <59495367.3080402@iogearbox.net>
References: <1495754003-21099-1-git-send-email-illusionist.neo@gmail.com> <CAGXu5jKmLNMR+uhM9Ov2XPW6kCjip_SjScgEH0fTFp6fQtKFiA@mail.gmail.com> <593E6B0F.8070901@iogearbox.net> <CAHgaXd+DW2bggto=2S9hOdMrtPTvhD2QN4rPf2V8iHewQpg-YA@mail.gmail.com> <CAHgaXdJrvKdzr3fJ1TMkC4foeVsZJDSVEwhDOeZGxQVsmoK2cQ@mail.gmail.com> <59419D1E.2060303@iogearbox.net> <CAHgaXdKMbFPgy-kKF0iDSAYo4CqLn9FRu9HwM+OfM-JWb9fNRQ@mail.gmail.com> <594813AA.5010001@iogearbox.net> <CAHgaXdLtX6yLdU3bMvS=g8FZ79sM_BW_+hHTMH=Mfk4TZqUnpw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <keescook@chromium.org>,
        Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Russell King <linux@armlinux.org.uk>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        LKML <linux-kernel@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Shubham Bansal <illusionist.neo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57352 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751028AbdFTQzZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 12:55:25 -0400
In-Reply-To: <CAHgaXdLtX6yLdU3bMvS=g8FZ79sM_BW_+hHTMH=Mfk4TZqUnpw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/20/2017 03:34 AM, Shubham Bansal wrote:
> Hi Daniel,
>
>> Sorry, had a travel over the weekend, so didn't read it in time.
>>
>> What is the issue with imitating in JIT what the interpreter is
>> doing as a starting point? That should be generic enough to handle
>> any case.

Why not proceeding this way first?

>> Otherwise you'd need some sort of reverse mapping since verifier
>> already converted BPF_CALL insns into relative helper addresses
>> in imm part.
>>
> Sorry but I don't get what you are trying to say. Can you explain it
> with an example?

Ok, probably the best is to check fixup_bpf_calls() in the verifier,
see the fn = prog->aux->ops->get_func_proto(insn->imm). It fetches the
helper function specification based on the BPF_FUNC_* enum and converts
the imm field into a relative address for the function such that if
you look at ___bpf_prog_run(), JMP_CALL label, the call address can
be reconstructed again. So you'd need some reverse mapping to get back
to the struct bpf_func_proto, so you can check argX_type that needs to
be extended with whether its JITable on 32bit or not.
