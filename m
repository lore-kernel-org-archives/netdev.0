From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 3/4] bpf: BPF for lightweight tunnel
 encapsulation
Date: Mon, 31 Oct 2016 09:19:55 +0100
Message-ID: <20161031081955.GA32374@pox.localdomain>
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
Received: from mail-wm0-f54.google.com ([74.125.82.54]:36559 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762069AbcJaIT6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 04:19:58 -0400
Received: by mail-wm0-f54.google.com with SMTP id p190so132253734wmp.1
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 01:19:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S35TOQumWFu1ha9nkNNOEwq2Y2VH6oCOK6F3HZg97omQgw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/30/16 at 06:28pm, Tom Herbert wrote:
> On Sun, Oct 30, 2016 at 2:47 PM, Thomas Graf <tgraf@suug.ch> wrote:
> > Instead of building complex logic, we can allow the program to return
> > a code to indicate when to perform another route lookup just as we do
> > for the redirect case. Just because the destination address has
> > changed may not require another lookup in all cases. A typical example
> > would be a program rewriting addresses for the default route to other
> > address which are always handled by the default route as well. An
> > unconditional lookup would hurt performance in many cases.
> 
> Right, that's why we rely on a dst cache. Any use of LWT that
> encapsulates or tunnels to a fixed destination (ILA, VXLAN, IPIP,
> etc.) would want to use the dst cache optimization to avoid the second
> lookup. The ILA LWT code used to call orig output and that worked as
> long as we could set the default router as the gateway "via". It was
> something we were able to deploy, but not a general solution.
> Integrating properly with routing gives a much better solution IMO.
> Note that David Lebrun's latest LWT Segment Routing patch does the
> second lookup with the dst cache to try to avoid it.

Yes, I saw both ILA and SR dst_cache. I was planning on addressing
the conditional reroute in a second step but it looks fairly simple
actually so I'm fine adding this in a v2 based on a return code. I
will limit lwt-bpf to AF_INET && AF_INET6 though.
