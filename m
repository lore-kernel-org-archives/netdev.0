From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v3 net-next 0/4] bpf: BPF for lightweight tunnel
 encapsulation
Date: Tue, 29 Nov 2016 15:15:15 +0100
Message-ID: <50764658-4bf7-966b-bc61-d6840d7c03f2@stressinduktion.org>
References: <cover.1480424542.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, tom@herbertland.com,
        roopa@cumulusnetworks.com
To: Thomas Graf <tgraf@suug.ch>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:37595 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755250AbcK2OPT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 09:15:19 -0500
In-Reply-To: <cover.1480424542.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas,

On 29.11.2016 14:21, Thomas Graf wrote:
> This series implements BPF program invocation from dst entries via the
> lightweight tunnels infrastructure. The BPF program can be attached to
> lwtunnel_input(), lwtunnel_output() or lwtunnel_xmit() and see an L3
> skb as context. Programs attached to input and output are read-only.
> Programs attached to lwtunnel_xmit() can modify and redirect, push headers
> and redirect packets.
> 
> The facility can be used to:
>  - Collect statistics and generate sampling data for a subset of traffic
>    based on the dst utilized by the packet thus allowing to extend the
>    existing realms.
>  - Apply additional per route/dst filters to prohibit certain outgoing
>    or incoming packets based on BPF filters. In particular, this allows
>    to maintain per dst custom state across multiple packets in BPF maps
>    and apply filters based on statistics and behaviour observed over time.
>  - Attachment of L2 headers at transmit where resolving the L2 address
>    is not required.
>  - Possibly many more.

Did you look at the cgroup based hooks which were added recently in
ip_finish_output for cgroup ebpf support and in general the cgroup bpf
subsystem. Does some of this solve the problem for you already? Would be
interesting to hear your opinion on that.

Thanks,
Hannes
