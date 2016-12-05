From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: bpf bounded loops. Was: [flamebait] xdp
Date: Mon, 5 Dec 2016 17:50:26 +0100
Message-ID: <b7c99fea-dfaa-a7a0-0694-d6abe649708e@stressinduktion.org>
References: <20161201091108.GF26507@breakpoint.cc>
 <20161201145834.GA569@pox.localdomain>
 <7e2be2fc-7c04-b333-59c7-43d4fcfcb451@stressinduktion.org>
 <20161201162814.GA31300@pox.localdomain>
 <583b8947-3395-8529-933b-08e1a86a0778@stressinduktion.org>
 <CALx6S36=Y0dSux+-omWXZKtxb73_g4+DXhPBawb79+UF6rp9rw@mail.gmail.com>
 <9b4264f8-26b9-a611-56f0-0840cecf9c44@stressinduktion.org>
 <20161202183903.GC54949@ast-mbp.thefacebook.com>
 <2f3ce25c-3f59-9120-7d09-619be9b58e7a@stressinduktion.org>
 <5726302e-3502-99c8-a4d9-a5278761cb5a@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, Thomas Graf <tgraf@suug.ch>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>
To: Edward Cree <ecree@solarflare.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:55170 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751884AbcLEQu3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 11:50:29 -0500
In-Reply-To: <5726302e-3502-99c8-a4d9-a5278761cb5a@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05.12.2016 17:40, Edward Cree wrote:
> On 02/12/16 19:25, Hannes Frederic Sowa wrote:
>> On 02.12.2016 19:39, Alexei Starovoitov wrote:
>>> Hannes,
>>> Not too long ago you proposed a very interesting idea to add
>>> support for bounded loops without adding any new bpf instructions and
>>> changing llvm (which was way better than my 'rep' like instructions
>>> I was experimenting with). I thought systemtap guys also wanted bounded
>>> loops and you were cooperating on the design, so I gave up on my work and
>>> was expecting an imminent patch from you. I guess it sounds like you know
>>> believe that bounded loops are impossible or I misunderstand your statement ?
>> Your argument was that it would need a new verifier as the current first
>> pass checks that we indeed can lay out the basic blocks as a DAG which
>> the second pass depends on. This would be violated.
> I may be completely mistaken here, but can't the verifier unroll the loop 'for
> verification' without it actually being unrolled in the program?
> I.e., any "proof that the loop terminates" should translate into "rewrite of
> the directed graph to make it a DAG, possibly duplicating a lot of insns", and
> you feed the rewritten graph to the verifier, while using the original loopy
> version as the actual program to store and later execute.
> Then the verifier happily checks things like array indices being valid, without
> having to know about the bounded loops.

That is what is already happening. E.g. __builtin_memset is expanded up
to 128 rounds (which is a lot) but at some point llvm doesn't do enoug
unrolling of that.

The BPF target configures that in
http://llvm.org/docs/doxygen/html/BPFISelLowering_8cpp_source.html on
line 166-169.

Bye,
Hannes
