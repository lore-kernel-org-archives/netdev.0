From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net-next] bpf/verifier: improve disassembly of BPF_END
 instructions
Date: Thu, 21 Sep 2017 20:58:12 +0100
Message-ID: <46aa4442-b8ed-e4c1-4897-8f650e23d448@solarflare.com>
References: <7013ee9d-a8e6-13fd-cc5f-86cf3d8bf4e0@solarflare.com>
 <20170921155215.jta52sesbiq54vri@ast-mbp>
 <4cfac985-4f99-cf85-fc15-c3ad1f8ff123@solarflare.com>
 <CAH3MdRWAHJS8Y8ketOAghYyorVUp6JijjZcSVY7gOiGAr7e_pw@mail.gmail.com>
 <207ecd4c-b1b4-3dcd-62a6-30824c19dbf7@solarflare.com>
 <59C4131D.8050003@iogearbox.net> <20170921194426.tnd5xos5irm3gred@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Y Song <ys114321@gmail.com>, David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([148.163.129.52]:54854 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751793AbdIUT6S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 15:58:18 -0400
In-Reply-To: <20170921194426.tnd5xos5irm3gred@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/09/17 20:44, Alexei Starovoitov wrote:
> On Thu, Sep 21, 2017 at 09:29:33PM +0200, Daniel Borkmann wrote:
>> More intuitive, but agree on the from_be/le. Maybe we should
>> just drop the "to_" prefix altogether, and leave the rest as is since
>> it's not surrounded by braces, it's also not a cast but rather an op.
That works for me.
> 'be16 r4' is ambiguous regarding upper bits.
>
> what about my earlier suggestion:
> r4 = (be16) (u16) r4
> r4 = (le64) (u64) r4
>
> It will be pretty clear what instruction is doing (that upper bits become zero).
Trouble with that is that's very *not* what C will do with those casts
 and it doesn't really capture the bidirectional/symmetry thing.  The
 closest I could see with that is something like `r4 = (be16/u16) r4`,
 but that's quite an ugly mongrel.
I think Daniel's idea of `be16`, `le32` etc one-arg opcodes is the
 cleanest and clearest.  Should it be
    r4 = be16 r4
 or just
    be16 r4
?  Personally I incline towards the latter, but admit it doesn't really
 match the syntax of other opcodes.


To shed a few more bikes, I did also wonder about the BPF_NEG opcode,
 which (if I'm reading the code correctly) currently renders as
    r4 = neg r4 0
    (u32) r4 = neg (u32) r4 0
That printing of the insn->imm, while harmless, is needless and
 potentially confusing.  Should we get rid of it?
