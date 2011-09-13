From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: pskb_copy() in tcp_transmit_skb()
Date: Tue, 13 Sep 2011 14:02:17 +0200
Message-ID: <CAL4Wiio=2MO2u53dvU1fqjeKqgQuVBmgDpZeVROMaZYcPPDpzA@mail.gmail.com>
References: <201109131221.37561.christoph.paasch@uclouvain.be>
	<4E6F2275.2050902@cn.fujitsu.com>
	<201109131355.55588.christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gaofeng <gaofeng@cn.fujitsu.com>, netdev@vger.kernel.org
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f170.google.com ([209.85.161.170]:57106 "EHLO
	mail-gx0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752933Ab1IMMJR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2011 08:09:17 -0400
Received: by gxk27 with SMTP id 27so634430gxk.1
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2011 05:09:16 -0700 (PDT)
In-Reply-To: <201109131355.55588.christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 13 septembre 2011 12:55, Christoph Paasch
<christoph.paasch@uclouvain.be> a =E9crit :
>
> Hi,
>
> On Tuesday 13 September 2011 wrote Gaofeng:
> > > I'm trying to understand the reason for the possible call to pskb=
_copy()
> > > in tcp_transmit_skb().
> > > I don't find, where we may have a cloned skb entering tcp_transmi=
t_skb().
> > >
> > > The original pskb_copy() came from tcp_retransmit_skb() (commit
> > > dfb4b9dceb35c567a595ae5e9d035cfda044a103).
> > > But from that point, the git-history does not show where the pskb=
_copy()
> > > is coming from.
> > >
> > >
> > > Does somebody has an idea, how a cloned skb can be passed to
> > > tcp_transmit_skb() and thus trigger this call to pskb_copy().
> >
> > maybe nat,nat can change the tcp packet header
>
> although NAT may change the TCP header, it is not doing an skb_clone(=
) - (at
> least I don't find it).
> Thus, we will not call pskb_copy() in tcp_transmit_skb() due to NAT.
>

I suggest you read dev_queue_xmit_nit() : Every xmit packet can be
cloned right here.

By the time tcp_retransmit_skb() is called, cloned skb might still be
in a AF_PACKET queue (or even a device TX queue)
