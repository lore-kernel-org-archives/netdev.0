From: "Daniel J Blueman" <daniel.blueman@gmail.com>
Subject: Re: sky2 v1.7 rx error...
Date: Tue, 26 Sep 2006 23:19:12 +0100
Message-ID: <6278d2220609261519i30ebc72cu759900b179725d9a@mail.gmail.com>
References: <6278d2220609261058y4b686489p813ef504f71bca4a@mail.gmail.com>
	 <20060926115526.4bb5b99b@freekitty>
	 <6278d2220609261309v148618a4p4315d17aedc79a7d@mail.gmail.com>
	 <20060926134417.689affb0@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Linux Netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.229]:16424 "EHLO
	wx-out-0506.google.com") by vger.kernel.org with ESMTP
	id S964773AbWIZWTN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 18:19:13 -0400
Received: by wx-out-0506.google.com with SMTP id s14so2328399wxc
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2006 15:19:12 -0700 (PDT)
To: "Stephen Hemminger" <shemminger@osdl.org>
In-Reply-To: <20060926134417.689affb0@freekitty>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26/09/06, Stephen Hemminger <shemminger@osdl.org> wrote:
> On Tue, 26 Sep 2006 21:09:31 +0100
> "Daniel J Blueman" <daniel.blueman@gmail.com> wrote:
>
> > The server processor is a Pentium-M 1.7GHz (ondemand governor, from
> > 0.6GHz -> 1.7GHz).
> >
> > Gigabit path from server -> switch -> client. Client runs WinXP,
> > Core2Duo 2.13GHz, Realtek RTL8168/8111 PCI-e NIC.
> >
> > Flow contol enabled in both directions, both for client and server:
> > sky2 lan0: Link is up at 1000 Mbps, full duplex, flow control both
> >
> > Jumbo frames are in use on the tx side of server only - MTU 9000. I
> > reproduced this with sky2 v1.7 with non-jumbo MTU 1500 frames too.
> >
> > Let me know if there is any further information I can grab and/or any
> > other settings/tweaks/patches I can try.
> >
> > Dan
> >
> > On 26/09/06, Stephen Hemminger <shemminger@osdl.org> wrote:
> > > On Tue, 26 Sep 2006 18:58:40 +0100
> > > "Daniel J Blueman" <daniel.blueman@gmail.com> wrote:
> > >
> > > > I got a this message with sky2 on 2.6.18 + the sky2 v1.7 patches - it
> > > > has different status bits set than before (0x977d977d):
> > > >
> > > > kernel: sky2 lan0: rx error, status 0x377d377d length 0
> > > >
> > > > Great work so far though - this race takes a while to hit!
> > > >
> > > > Dan
> > >
> > > What speed processor? Are you using receive flow control? Are you
> > > using Jumbo frames?
> > >
> > > --
> > > Stephen Hemminger <shemminger@osdl.org>
>
> Statistics?
>         ethtool -S eth0
>
> Does it hang after this? It looks like a receive fifo overflow, that happens
> when the receive ring gets full.  You could try increasing RX_LE_SIZE from 512
> to 1024.  That would eat more memory (510 packets) but might avoid the
> problem.
>
> Other possible solutions would be to reduce the coalescing timer values
> with ethtool.
>         ethtool -c eth1
>         ethtool -C eth1 rx-usecs 10 rx-usecs-irq 10 rx-iframes-irq 4

When it happens next time, I'll send you the stats. For now, I've
increased the receive list entries to 1024. Ping me if you'd like me
to test anything else - it may take a few weeks before I find this
again (unless I try).

Dan
-- 
Daniel J Blueman
