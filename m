From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: TCP performance regression
Date: Mon, 11 Nov 2013 08:17:02 -0800
Message-ID: <1384186622.16391.44.camel@edumazet-glaptop2.roam.corp.google.com>
References: <21120.27501.32323.332316@gargle.gargle.HOWL>
	 <1384149326.16391.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <21120.29720.673157.151074@gargle.gargle.HOWL>
	 <1384152853.16391.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 <21120.37647.979237.40802@gargle.gargle.HOWL>
	 <1384180069.16391.32.camel@edumazet-glaptop2.roam.corp.google.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B73F9@saturn3.aculab.com>
	 <1384183799.16391.39.camel@edumazet-glaptop2.roam.corp.google.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B73FB@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sujith Manoharan <sujith@msujith.org>, netdev@vger.kernel.org,
	Dave Taht <dave.taht@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:35810 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754574Ab3KKQRI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 11:17:08 -0500
Received: by mail-pb0-f52.google.com with SMTP id rr4so5387662pbb.39
        for <netdev@vger.kernel.org>; Mon, 11 Nov 2013 08:17:07 -0800 (PST)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B73FB@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-11-11 at 15:43 +0000, David Laight wrote:
> > > Or, maybe:
> > > 5) call skb_orphan() (I think that is the correct function) when transmit
> > >    packets are given to the hardware.
> > 
> > This is the worth possible solution, as it basically re-enables
>               ^^^^^ worst ?
> > bufferbloat again.
> 
> It should be ok if the mac driver only gives the hardware a small
> number of bytes/packets - or one appropriate for the link speed.

There is some confusion here.

mvneta has a TX ring buffer, which can hold up to 532 TX descriptors.

If this driver used skb_orphan(), a single TCP flow could use the whole
TX ring.

TCP Small Queue would only limit the number of skbs on Qdisc.

Try then to send a ping message, it will have to wait a lot.
