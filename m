From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Wed, 21 Sep 2016 08:39:27 -0700
Message-ID: <57E2A9AF.4010201@fb.com>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
 <1474408824-418864-2-git-send-email-tom@herbertland.com>
 <20160920224416.GF3291@pox.localdomain>
 <CALx6S36FVU7bNu3JudZuET-VdFND2ZO7n9A7k--qsZVyxTvcpQ@mail.gmail.com>
 <20160920230927.GG3291@pox.localdomain>
 <CALx6S37oniKp1JOeiygzr0RiQojj651ONqBgyvcJvqHj5-aT5g@mail.gmail.com>
 <20160920234347.GH3291@pox.localdomain>
 <CALx6S35LmUtwRA85Kg6s7OR=e5Pj9ssqmWLsjtmXfZTXeG02zQ@mail.gmail.com>
 <20160921115545.GA12789@pox.localdomain>
 <CALx6S35Xctd-aA8DF1_vypMDejiGXcud6=UO33dqgvO60W0DZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        "Alexei Starovoitov" <alexei.starovoitov@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: Tom Herbert <tom@herbertland.com>, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:58382 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S933548AbcIUPju (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 11:39:50 -0400
In-Reply-To: <CALx6S35Xctd-aA8DF1_vypMDejiGXcud6=UO33dqgvO60W0DZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/21/16 7:19 AM, Tom Herbert wrote:
> #1: Should we allow alternate code to run in XDP other than BPF?

separate nft hook - yes
generic hook - no
since it's one step away from kernel modules abusing this hook.
pass/drop/tx of raw buffer at the driver level is a perfect
interface to bypass everything in the stack.
The tighter we make it the better.

If nft and bpf are both not flexible enough to express
dataplane functionality we should extend them instead of
writing C code or kernel modules.

On bpf side we're trying very hard to kill any dream of
interoperability with kernel modules.
The map and prog type registration is done in a way to make
it impossible for kernel modules to register their own
map and program types or provide their own helper functions.

nfhooks approach is very lax at that and imo it was a mistake,
since there are plenty of out of tree modules that using nf hooks
and plenty of in-tree modules that are barely maintained.

> #2: If #1 is true what is the best way to implement that?

Add separate nft hook that doesn't interfere in any way
with bpf hook at xdp level.
The order nft-first or bpf-first or exclusive attach
doesn't matter to me. These are details to be discussed.
