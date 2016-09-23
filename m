From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Fri, 23 Sep 2016 07:26:41 -0700
Message-ID: <57E53BA1.3060609@fb.com>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
 <1474408824-418864-2-git-send-email-tom@herbertland.com>
 <06280af8-5451-c423-d295-a5f3f51e63cf@mojatatu.com>
 <20160923150040.0e3dc7d5@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>,
        <tariqt@mellanox.com>, <bblanco@plumgrid.com>,
        <alexei.starovoitov@gmail.com>, <eric.dumazet@gmail.com>,
        Thomas Graf <tgraf@suug.ch>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:53167 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1759994AbcIWO06 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 10:26:58 -0400
In-Reply-To: <20160923150040.0e3dc7d5@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/23/16 6:00 AM, Jesper Dangaard Brouer wrote:
> To support Tom's case, with eBPF, I think we would have to implement
> specific eBPF helper functions that can do the ILA table lookups.  And
> then need a userspace component to load the eBPF program.  Why add all
> this, when we could contain all this in the kernel, and simply call
> this as native C-code via the XDP hook?

well, ILA router was written in BPF already :) Once for tc+clsact
and once for XDP. In both cases no extra bpf helpers were needed.
Due to this use case we added an optimization to be able to do
a map lookup with packet data directly (instead of copying packet
bytes to stack and pointing map_lookup helper to stack).
Looks like those ila router patches never made it to the list.
I'll dig them out and forward.
