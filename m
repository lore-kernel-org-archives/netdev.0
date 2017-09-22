From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net-next] bpf/verifier: improve disassembly of BPF_END
 instructions
Date: Fri, 22 Sep 2017 17:23:58 +0100
Message-ID: <7c1ab2b8-e65d-3b09-f9f0-9fd13c1ceccf@solarflare.com>
References: <4cfac985-4f99-cf85-fc15-c3ad1f8ff123@solarflare.com>
 <CAH3MdRWAHJS8Y8ketOAghYyorVUp6JijjZcSVY7gOiGAr7e_pw@mail.gmail.com>
 <207ecd4c-b1b4-3dcd-62a6-30824c19dbf7@solarflare.com>
 <59C4131D.8050003@iogearbox.net> <20170921194426.tnd5xos5irm3gred@ast-mbp>
 <46aa4442-b8ed-e4c1-4897-8f650e23d448@solarflare.com>
 <CAH3MdRVK-=pL8YCz44BPCmHhuZE_CRfih0QdZPLa=mpE_uoA_Q@mail.gmail.com>
 <ec7d0485-11f4-4fdb-0b87-1fb0afdb4f11@solarflare.com>
 <CAH3MdRVCf_wLoC7WOfaL2L2px3aYVWUhWxarMsyJdD7_E9fv_Q@mail.gmail.com>
 <CAH3MdRXgVtVjhYQkRopPKvL+4+NaTRRJoJq6XD_S-Dra69j0hA@mail.gmail.com>
 <20170922151614.bg4ovrp6m27cppr7@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Y Song <ys114321@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:38369 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752013AbdIVQYP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 12:24:15 -0400
In-Reply-To: <20170922151614.bg4ovrp6m27cppr7@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/09/17 16:16, Alexei Starovoitov wrote:
> looks like we're converging on
> "be16/be32/be64/le16/le32/le64 #register" for BPF_END.
> I guess it can live with that. I would prefer more C like syntax
> to match the rest, but llvm parsing point is a strong one.
Yep, agreed.  I'll post a v2 once we've settled BPF_NEG.
> For BPG_NEG I prefer to do it in C syntax like interpreter does:
>         ALU_NEG:
>                 DST = (u32) -DST;
>         ALU64_NEG:
>                 DST = -DST;
> Yonghong, does it mean that asmparser will equally suffer?
Correction to my earlier statements: verifier will currently disassemble
 neg as:
(87) r0 neg 0
(84) (u32) r0 neg (u32) 0
 because it pretends 'neg' is a compound-assignment operator like +=.
The analogy with be16 and friends would be to use
    neg64 r0
    neg32 r0
 whereas the analogy with everything else would be
    r0 = -r0
    r0 = (u32) -r0
 as Alexei says.
I'm happy to go with Alexei's version if it doesn't cause problems for llvm.
