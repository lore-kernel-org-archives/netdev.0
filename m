From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: bpf bounded loops. Was: [flamebait] xdp
Date: Tue, 6 Dec 2016 12:35:53 +0100
Message-ID: <7c961590-2f25-b5e0-eccd-016ecf5ea88a@stressinduktion.org>
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
 <b7c99fea-dfaa-a7a0-0694-d6abe649708e@stressinduktion.org>
 <aafa452d-26dd-d58b-2649-21ccce9370a4@solarflare.com>
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
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:58279 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752328AbcLFLgI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 06:36:08 -0500
In-Reply-To: <aafa452d-26dd-d58b-2649-21ccce9370a4@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05.12.2016 17:54, Edward Cree wrote:
> On 05/12/16 16:50, Hannes Frederic Sowa wrote:
>> On 05.12.2016 17:40, Edward Cree wrote:
>>> I may be completely mistaken here, but can't the verifier unroll the loop 'for
>>> verification' without it actually being unrolled in the program?
>>> I.e., any "proof that the loop terminates" should translate into "rewrite of
>>> the directed graph to make it a DAG, possibly duplicating a lot of insns", and
>>> you feed the rewritten graph to the verifier, while using the original loopy
>>> version as the actual program to store and later execute.
>>> Then the verifier happily checks things like array indices being valid, without
>>> having to know about the bounded loops.
>> That is what is already happening. E.g. __builtin_memset is expanded up
>> to 128 rounds (which is a lot) but at some point llvm doesn't do enoug
>> unrolling of that.
>>
>> The BPF target configures that in
>> http://llvm.org/docs/doxygen/html/BPFISelLowering_8cpp_source.html on
>> line 166-169.
> I think you're talking about the _compiler_ unrolling loops before it
> submits the program to the kernel.  I'm talking about having the _verifier_
> unroll them, so that we can execute the original (non-unrolled) version.
> Or am I misunderstanding?

Ah, in the verifier this would be part of flow control analysis what we
are talking about in the other part of this thread.

Bye,
Hannes
