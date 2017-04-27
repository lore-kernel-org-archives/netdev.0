From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: ipsec doesn't route TCP with 4.11 kernel
Date: Thu, 27 Apr 2017 10:42:38 +0200
Message-ID: <20170427084238.GX2649@secunet.com>
References: <CADJev78Cs0VBdagtfU-71pv3HHC5Vq41UXQee856aVbUqEqAYg@mail.gmail.com>
 <CAM_iQpWT5tF5+LpoTP98JNJ=440jEkxHFkn8=jtAsZgondN49A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Don Bowman <db@donbowman.ca>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:56284 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754414AbdD0I43 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 04:56:29 -0400
Content-Disposition: inline
In-Reply-To: <CAM_iQpWT5tF5+LpoTP98JNJ=440jEkxHFkn8=jtAsZgondN49A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 10:01:34PM -0700, Cong Wang wrote:
> (Cc'ing netdev and IPSec maintainers)
> 
> On Tue, Apr 25, 2017 at 6:08 PM, Don Bowman <db@donbowman.ca> wrote:
> > I'm not sure how to describe this.
> >
> > 4.11rc2 worked, after that, no.

We had some recent IPsec GRO changes, this could influence TCP.
But these changes were introduced before rc2. If I read this correct,
the regression was introduced between rc2 and rc3, right?

> >
> > My ipsec tunnel comes up ok.

When talking about IPsec, I guess you use ESP, right?

> > ICMP works. UDP works. But TCP, the
> > sender [which is the ipsec client] does not reach the destination.
> >
> > Its not a routing rule issue (since ICMP/UDP work).
> > Its not a traffic selector just selecting TCP (I think) since ipsec
> > status shows just a subnet, no protocol.
> >
> > Using tcpdump:
> > # iptables -t mangle -I PREROUTING -m policy --pol ipsec --dir in -j
> > NFLOG --nflog-group 5
> > # iptables -t mangle -I POSTROUTING -m policy --pol ipsec --dir out -j
> > NFLOG --nflog-group 5
> > # tcpdump -s 0 -n -i nflog:5
> >
> > I see that it thinks it is sending the TCP packet, but the server end
> > does not receive.
> >
> > Does anyone have any suggestion to try?

If it is a GRO issue, then it is on the receive side, could you do
tcpdump on the receiving interface to see what you get there?

What shows /proc/net/xfrm_stat?

Can you do 'ip -s x s' to see if the SAs are used?

Do you have INET_ESP_OFFLOAD enabled?
