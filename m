From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v3 net-next RFC] Generic XDP
Date: Tue, 18 Apr 2017 11:47:59 +0200
Message-ID: <1492508879.2472.13.camel@sipsolutions.net>
References: <20170412.145415.1441440342830198148.davem@davemloft.net>
         <20170413042036.GA46229@ast-mbp.thefacebook.com>
         <1492063856.19193.4.camel@sipsolutions.net>
         <20170413.113810.703136630867928001.davem@davemloft.net>
         <20170414194105.GA51147@ast-mbp.thefacebook.com>
         (sfid-20170414_214112_825421_99F913DC)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xdp-newbies@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:47340 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754871AbdDRJsE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Apr 2017 05:48:04 -0400
In-Reply-To: <20170414194105.GA51147@ast-mbp.thefacebook.com> (sfid-20170414_214112_825421_99F913DC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-04-14 at 12:41 -0700, Alexei Starovoitov wrote:
> 
> ahh. i thought all drivers do at least copy-break (256) bytes 

We do copy-break, but that's only applicable when there's no non-linear 
data left afterwards :)

> or copy
> get_headlen or build_skb the whole thing.
> Since wireless does eth_hlen, then yeah, skb_linearize() is the only
> way.

It's rather difficult to do this in wifi because we'd need to parse
deep into the packet - at a point where we haven't even parsed the
802.11 header (which has variable length) fully.

So that leaves us to do it at the very end, after conversion to
ethernet format, but then it feels pointless since we might as well let
the rest of the stack do it.

> I guess any driver that would care about XDP performance would either
> implement in-driver XDP or make sure that skb_linearize() doesn't
> happen in generic XDP by doing build_skb() with the whole packet.
> The driver can be smart and avoid doing copy-break if generic XDP is
> on.

Indeed. I think this is less about performance than ease of
experimentation.

johannes
