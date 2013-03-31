From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RX/dropped counter values for tagged packets
Date: Sat, 30 Mar 2013 22:44:24 -0700
Message-ID: <1364708664.5113.139.camel@edumazet-glaptop>
References: <CAOxq_8OrE6=XtJ9TDbL7NH9313-WutZPZP8=cRBH7pVUdBDvCg@mail.gmail.com>
	 <CAOxq_8OBcHktjmkwiz2j=DXDAdNx3t7D_nTmDtuJudfs49VNrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxdev@anirban.org
To: Ani Sinha <ani@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f44.google.com ([209.85.210.44]:65445 "EHLO
	mail-da0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754451Ab3CaFo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Mar 2013 01:44:27 -0400
Received: by mail-da0-f44.google.com with SMTP id z20so676031dae.31
        for <netdev@vger.kernel.org>; Sat, 30 Mar 2013 22:44:27 -0700 (PDT)
In-Reply-To: <CAOxq_8OBcHktjmkwiz2j=DXDAdNx3t7D_nTmDtuJudfs49VNrg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-03-30 at 20:30 -0700, Ani Sinha wrote:

> On Sun, Mar 24, 2013 at 9:43 PM, Ani Sinha <ani@aristanetworks.com> wrote:
> > hello everyone :
> >
> > Please bear with me if you think I said something wrong.
> >
> > I was looking at the netif_receive_skb() code and it seems to me that
> > for vlan tagged packets, the counters are manipulated at two different
> > places. One is from vlan_do_receive() where the receive counters are
> > incremented. The other counter (the dropped counter) is incremented at
> > the very end of netif_receive_skb() when there are no takers for this
> > packet. The dropped counts are incremented for skb->dev->rx_dropped
> > whereas the receive counts are incremented for the vlan device
> > specific private stat counter values. When the numbers are reported on
> > /proc/net/dev (from where ifconfig gets the numbers), these two stat
> > counters are combined together (see dev_get_stats() where rx_dropped
> > is added to the device private stat numbers). So if no one is
> > receiving the tagged packets, it will be reported both as received and
> > dropped! I wonder whether I am analyzing it wrong or whether no one
> > has noticed this before or whether this is intentional.
> >
> > Any  clarification will be greatly appreciated. Again, I could be
> > wrong looking at the code, so please bear with me.
> >

I don't know, I am not reading this code like you, I see no problem.

If vlan_do_receive() return true, we "goto another_round" to deliver the
packt to vlan device.

vlan_do_receive() doesn't deliver the packet at all. It only prepares
the "another_round"

So if packet is delivered to vlan, we don't increment rx_dropped.

Just try by yourself, it is fine.
