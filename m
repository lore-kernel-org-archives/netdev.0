From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 3/4] bpf: BPF for lightweight tunnel encapsulation
Date: Mon, 31 Oct 2016 07:17:41 -0700
Message-ID: <CALx6S34hHZDdtZgLBZzw-QiOc80tjrLAuAVBDeWRuUonR1MfXA@mail.gmail.com>
References: <cover.1477827877.git.tgraf@suug.ch> <2ab47e198828261438e8762ef484a6023481a756.1477827877.git.tgraf@suug.ch>
 <CALx6S35PMvoMZ-L0bC4R=Q9qw=V5N7JY_Xbit0BffFccH0nMgw@mail.gmail.com>
 <20161030214717.GA27148@pox.localdomain> <CALx6S35TOQumWFu1ha9nkNNOEwq2Y2VH6oCOK6F3HZg97omQgw@mail.gmail.com>
 <20161031125906.GB32374@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        roopa <roopa@cumulusnetworks.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:36628 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S943378AbcJaORn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 10:17:43 -0400
Received: by mail-qk0-f195.google.com with SMTP id z190so9956751qkc.3
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 07:17:43 -0700 (PDT)
In-Reply-To: <20161031125906.GB32374@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 31, 2016 at 5:59 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 10/30/16 at 06:28pm, Tom Herbert wrote:
>> Right, that's why we rely on a dst cache. Any use of LWT that
>> encapsulates or tunnels to a fixed destination (ILA, VXLAN, IPIP,
>> etc.) would want to use the dst cache optimization to avoid the second
>> lookup. The ILA LWT code used to call orig output and that worked as
>> long as we could set the default router as the gateway "via". It was
>> something we were able to deploy, but not a general solution.
>> Integrating properly with routing gives a much better solution IMO.
>> Note that David Lebrun's latest LWT Segment Routing patch does the
>> second lookup with the dst cache to try to avoid it.
>
> Noticed while implementing this: How does ILA ensure that dst_output()
> is not invoked in a circular manner?
>
> dstA->output() -> dstB->otuput() -> dstA->output() -> ...

It doesn't. We'll need to add a check for that. Maybe the rule should
be that an skbuff is only allowed to hit one LWT route?

Another scenario to consider: Suppose someone is doing protocol
translation like in RFC7915. This is one of operations we'd need with
ILA or GRE to implement an IPv4 overlay network over IPv6. Would this
be allowed/supported in LWT BPF?

Tom
