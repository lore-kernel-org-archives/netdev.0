From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Tue, 20 Sep 2016 17:13:13 -0700
Message-ID: <57E1D099.4050403@fb.com>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
 <1474408824-418864-2-git-send-email-tom@herbertland.com>
 <20160920224416.GF3291@pox.localdomain>
 <CALx6S36FVU7bNu3JudZuET-VdFND2ZO7n9A7k--qsZVyxTvcpQ@mail.gmail.com>
 <20160920230927.GG3291@pox.localdomain>
 <CALx6S37oniKp1JOeiygzr0RiQojj651ONqBgyvcJvqHj5-aT5g@mail.gmail.com>
 <20160920234347.GH3291@pox.localdomain>
 <CALx6S35LmUtwRA85Kg6s7OR=e5Pj9ssqmWLsjtmXfZTXeG02zQ@mail.gmail.com>
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
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:56371 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752187AbcIUANm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 20:13:42 -0400
In-Reply-To: <CALx6S35LmUtwRA85Kg6s7OR=e5Pj9ssqmWLsjtmXfZTXeG02zQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/20/16 4:59 PM, Tom Herbert wrote:
> I am looking at using this for ILA router. The problem I am hitting is
> that not all packets that we need to translate go through the XDP
> path. Some would go through the kernel path, some through XDP path but
> that would mean I need parallel lookup tables to be maintained for the
> two paths which won't scale. ILA translation is so trivial and not
> really something that we need to be user programmable, the fast path
> is really for accelerating an existing kernel capability. If I can
> reuse the kernel code already written and the existing kernel data
> structures to make a fast path in XDP there is a lot of value in that
> for me.

sounds like you want to add hard coded ILA rewriter to the driver
instead of doing it as BPF program?!
That is 180 degree turn vs the whole protocol ossification tune
that I thought you strongly believe in.

What kernel data structures do you want to reuse?
ILA rewriter needs single hash lookup. Several different
types of hash maps exist on bpf side already and
even more are coming that will be usable by both tc and xdp side.
csum adjustment? we have them for tc. Not for xdp yet,
but it's trivial to allow them on xdp side too.
May be we should talk about real motivation for the patches
and see what is the best solution.
