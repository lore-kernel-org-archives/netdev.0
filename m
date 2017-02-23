From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Software loopback with phy 88E1116R and marvell MV78100 gbe
Date: Thu, 23 Feb 2017 14:36:37 +0100
Message-ID: <20170223133637.GA20118@lunn.ch>
References: <CABmfJQYEqWzPtfieaym-4KhG5f0PBHNDQzuT0Uk_bz-2WC3zag@mail.gmail.com>
 <20170223105958.GC14312@lunn.ch>
 <CABmfJQZz=8wyTUT4oZrB4zMKbwYSJyyFqPsE+eRVcU-LVz-ibA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Paolo Minazzi <paolo.minazzi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50013 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751070AbdBWNgy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Feb 2017 08:36:54 -0500
Content-Disposition: inline
In-Reply-To: <CABmfJQZz=8wyTUT4oZrB4zMKbwYSJyyFqPsE+eRVcU-LVz-ibA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 23, 2017 at 12:28:10PM +0100, Paolo Minazzi wrote:
> On Thu, Feb 23, 2017 at 11:59 AM, Andrew Lunn <andrew@lunn.ch> wrote:
> >> I tried to do the same things on 88E1116R, setting the but 14 of reg 0.
> >> But If I do it I lose the link, and the test program does not work.
> >> I tried to force the link in software, but seems the controller send
> >> packets but it is not able to receive them.
> >> Is possibile to do such a software loopback on 88E1116R ?
> >
> > Hi Paolo
> >
> > What you are talking about here is MAC loopback. Packets are looped
> > back at the MAC level. The copper side will be left idle, and so the
> > link will be lost. This explains why you are seeing link down..
> 
> Hi Andrew,
> if I understand correctly there are 3 type of loopback.
> [1] loopback at the MAC level
> [2] loopback at the phy level
> [3] loopback with a physical loopback cable

Plus there is [4] loopback in the other direction. I.E, everything
received on the copper is sent straight back out the copper.

The PHY datasheet often call [2] above MAC loopback, since what is
receives from the MAC it loops back to the MAC. [4] can be called line
loopback, what comes in on the line is looped back to the line.
 
> [1] is enabled programming ethernet registers
> [2] is enabled programming the PHY
> [3] is done at hardware level with a physical loopback cable
> 
> > What you might need to do is extend marvell_update_link() to check if
> > MAC loopback is happening, and if so, say the link is up.
> 
> I agree. For example some driver  (also marvell driver) check the link before
> do a TX. If there is not a good link the TX is dropped.
> So I have to force link up with a bit in a register (or hacking the
> driver) to permit TX.

Try bit 10, register 16 for the Marvell PHY. This should force the
link up.
 
 Andrew
