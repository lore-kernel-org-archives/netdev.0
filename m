From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Let's do P4
Date: Wed, 2 Nov 2016 16:27:11 +0100
Message-ID: <20161102152711.GL1713@nanopsycho.orion>
References: <20161029154903.25deb6db@jkicinski-Precision-T1700>
 <5814D25D.9070200@gmail.com>
 <20161030074458.GB1686@nanopsycho.orion>
 <20161030102649.GE1810@pox.localdomain>
 <20161030163836.GC1686@nanopsycho.orion>
 <20161030223903.GA6658@ast-mbp.hil-sfehihf.abq.wayport.net>
 <20161031093922.GA2895@nanopsycho.orion>
 <58194F83.9020205@iogearbox.net>
 <20161102081404.GE1713@nanopsycho.orion>
 <581A04CA.5020808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Thomas Graf <tgraf@suug.ch>, Jakub Kicinski <kubakici@wp.pl>,
        netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        roopa@cumulusnetworks.com, simon.horman@netronome.com,
        ast@kernel.org, prem@barefootnetworks.com,
        hannes@stressinduktion.org, jbenc@redhat.com, tom@herbertland.com,
        mattyk@mellanox.com, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        linville@tuxdriver.com, andy@greyhouse.net, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, ivecera@redhat.com,
        Maciej =?utf-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:34637 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755890AbcKBP1N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 11:27:13 -0400
Received: by mail-wm0-f41.google.com with SMTP id u144so24584759wmu.1
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 08:27:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <581A04CA.5020808@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Nov 02, 2016 at 04:22:50PM CET, john.fastabend@gmail.com wrote:

[...]

>>>
>>> What is your compilerA? Is that part of tc in user space? Maybe linked
>> 
>> It is something that transforms original p4 source to some intermediate
>> form, easy to be processed by in-kernel compilers.
>> 
>> 
>>> against LLVM lib, for example? If you really want some sw path, can't tc
>>> do this transparently from user space instead when it gets a netlink error
>>> that it cannot get offloaded (and thus switch internally to f_bpf's loader)?
>> 
>> In real life, user will most probably use p4 for hw programming, but the
>> sw fallback will be done in bpf directly. In that case, he would use
>> cls_bfp SKIP_HW
>> cls_p4 SKIP_SW
>> 
>> But in order to allow cls_p4 offloading to hw, we need in-kernel
>> interpreter. That is purpose of compilerB to take agvantage of bpf, but
>> the in-kernel interpreter could be implemented differently.
>> 
>
>But this is the issue. We openly acknowledge it wont actually be used.
>We have multiple user space compilers that generate at least half way
>reasonable ebpf code that is being used in real deployments and
>works great for testing. This looks like pure overhead to satisfy this
>hw/sw parity checkbox and I can't see why anyone would use it or even
>maintain it. Looks like a checkbox and I like to avoid useless work that
>is likely to bit rot.

That's how it works I'm afraid, unless something changed from the last
time we discussed this. Without in-kernel implementation, it's a bypass.

Dave?
