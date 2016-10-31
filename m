From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 3/4] bpf: BPF for lightweight tunnel
 encapsulation
Date: Mon, 31 Oct 2016 13:59:07 +0100
Message-ID: <20161031125906.GB32374@pox.localdomain>
References: <cover.1477827877.git.tgraf@suug.ch>
 <2ab47e198828261438e8762ef484a6023481a756.1477827877.git.tgraf@suug.ch>
 <CALx6S35PMvoMZ-L0bC4R=Q9qw=V5N7JY_Xbit0BffFccH0nMgw@mail.gmail.com>
 <20161030214717.GA27148@pox.localdomain>
 <CALx6S35TOQumWFu1ha9nkNNOEwq2Y2VH6oCOK6F3HZg97omQgw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        roopa <roopa@cumulusnetworks.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:38732 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942322AbcJaM7K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 08:59:10 -0400
Received: by mail-wm0-f42.google.com with SMTP id n67so227084486wme.1
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 05:59:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S35TOQumWFu1ha9nkNNOEwq2Y2VH6oCOK6F3HZg97omQgw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/30/16 at 06:28pm, Tom Herbert wrote:
> Right, that's why we rely on a dst cache. Any use of LWT that
> encapsulates or tunnels to a fixed destination (ILA, VXLAN, IPIP,
> etc.) would want to use the dst cache optimization to avoid the second
> lookup. The ILA LWT code used to call orig output and that worked as
> long as we could set the default router as the gateway "via". It was
> something we were able to deploy, but not a general solution.
> Integrating properly with routing gives a much better solution IMO.
> Note that David Lebrun's latest LWT Segment Routing patch does the
> second lookup with the dst cache to try to avoid it.

Noticed while implementing this: How does ILA ensure that dst_output()
is not invoked in a circular manner?

dstA->output() -> dstB->otuput() -> dstA->output() -> ...
