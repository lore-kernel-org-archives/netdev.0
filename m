From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Let's do P4
Date: Sat, 29 Oct 2016 16:55:32 +0200
Message-ID: <20161029145532.GI1692@nanopsycho.orion>
References: <20161029075328.GB1692@nanopsycho.orion>
 <20161029154903.25deb6db@jkicinski-Precision-T1700>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
        Maciej =?utf-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:37939 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751075AbcJ2Ozf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 10:55:35 -0400
Received: by mail-wm0-f52.google.com with SMTP id n67so159816747wme.1
        for <netdev@vger.kernel.org>; Sat, 29 Oct 2016 07:55:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20161029154903.25deb6db@jkicinski-Precision-T1700>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Oct 29, 2016 at 04:49:03PM CEST, kubakici@wp.pl wrote:
>On Sat, 29 Oct 2016 09:53:28 +0200, Jiri Pirko wrote:
>> Hi all.
>> 
>> The network world is divided into 2 general types of hw:
>> 1) network ASICs - network specific silicon, containing things like TCAM
>>    These ASICs are suitable to be programmed by P4.
>> 2) network processors - basically a general purpose CPUs
>>    These processors are suitable to be programmed by eBPF.
>> 
>> I believe that by now, the most people came to a conclusion that it is
>> very difficult to handle both types by either P4 or eBPF. And since
>> eBPF is part of the kernel, I would like to introduce P4 into kernel
>> as well. Here's a plan:
>> 
>> 1) Define P4 intermediate representation
>>    I cannot imagine loading P4 program (c-like syntax text file) into
>>    kernel as is. That means that as the first step, we need find some
>>    intermediate representation. I can imagine someting in a form of AST,
>>    call it "p4ast". I don't really know how to do this exactly though,
>>    it's just an idea.
>> 
>>    In the end there would be a userspace precompiler for this:
>>    $ makep4ast example.p4 example.ast
>
>Maybe stating the obvious, but IMHO defining the IR is the hardest part.
>eBPF *is* the IR, we can compile C, P4 or even JIT Lua to eBPF.  The
>AST/IR for switch pipelines should allow for similar flexibility.
>Looser coupling would also protect us from changes in spec of the high
>level language.

Agreed. I agree with you point this would be nice to have it done in a
generic way. However, I'm not aware of any other language similar to p4.
