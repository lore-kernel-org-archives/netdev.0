From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: Let's do P4
Date: Sat, 29 Oct 2016 15:49:03 +0100
Message-ID: <20161029154903.25deb6db@jkicinski-Precision-T1700>
References: <20161029075328.GB1692@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, tgraf@suug.ch,
        jhs@mojatatu.com, roopa@cumulusnetworks.com,
        john.fastabend@gmail.com, simon.horman@netronome.com,
        ast@kernel.org, daniel@iogearbox.net, prem@barefootnetworks.com,
        hannes@stressinduktion.org, jbenc@redhat.com, tom@herbertland.com,
        mattyk@mellanox.com, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        linville@tuxdriver.com, andy@greyhouse.net, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, ivecera@redhat.com,
        Maciej =?UTF-8?B?xbtlbmN6eWtvd3NraQ==?= <zenczykowski@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:23641 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750827AbcJ2OtN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 29 Oct 2016 10:49:13 -0400
In-Reply-To: <20161029075328.GB1692@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 29 Oct 2016 09:53:28 +0200, Jiri Pirko wrote:
> Hi all.
> 
> The network world is divided into 2 general types of hw:
> 1) network ASICs - network specific silicon, containing things like TCAM
>    These ASICs are suitable to be programmed by P4.
> 2) network processors - basically a general purpose CPUs
>    These processors are suitable to be programmed by eBPF.
> 
> I believe that by now, the most people came to a conclusion that it is
> very difficult to handle both types by either P4 or eBPF. And since
> eBPF is part of the kernel, I would like to introduce P4 into kernel
> as well. Here's a plan:
> 
> 1) Define P4 intermediate representation
>    I cannot imagine loading P4 program (c-like syntax text file) into
>    kernel as is. That means that as the first step, we need find some
>    intermediate representation. I can imagine someting in a form of AST,
>    call it "p4ast". I don't really know how to do this exactly though,
>    it's just an idea.
> 
>    In the end there would be a userspace precompiler for this:
>    $ makep4ast example.p4 example.ast

Maybe stating the obvious, but IMHO defining the IR is the hardest part.
eBPF *is* the IR, we can compile C, P4 or even JIT Lua to eBPF.  The
AST/IR for switch pipelines should allow for similar flexibility.
Looser coupling would also protect us from changes in spec of the high
level language.
