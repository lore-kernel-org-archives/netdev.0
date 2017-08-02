From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/2] [for 4.13] net: qcom/emac: disable flow control
 autonegotiation by default
Date: Wed, 2 Aug 2017 15:38:01 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0049282@AcuExch.aculab.com>
References: <1501623460-3575-1-git-send-email-timur@codeaurora.org>
 <1501623460-3575-2-git-send-email-timur@codeaurora.org>
 <063D6719AE5E284EB5DD2968C1650D6DD00490C0@AcuExch.aculab.com>
 <77de100a-42b1-1e0d-6545-cadb0067eec6@codeaurora.org>
 <063D6719AE5E284EB5DD2968C1650D6DD00491F6@AcuExch.aculab.com>
 <115c4698-cfcb-83dc-e70b-89207ef326a8@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Timur Tabi' <timur@codeaurora.org>,
        "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.192]:60430 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751162AbdHBPiJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 11:38:09 -0400
In-Reply-To: <115c4698-cfcb-83dc-e70b-89207ef326a8@codeaurora.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi
> Sent: 02 August 2017 16:09
> On 08/02/2017 09:51 AM, David Laight wrote:
> > Sending pause frames just tells the adjacent switch not to send you packets
> > (because you'll discard them).
> > Since the idea is to avoid the discards, the switch will buffer the
> > packets it would have sent.
> > The buffers in the switch then fill up with packets it isn't sending you.
> 
> I was under the impression that the switch forwards the pause frames to
> other devices, so that the transmitting NIC can stop sending the data,

Most of my ethernet knowledge predates FDX :-)
It wouldn't make any sense to try to use the source address of a pause
frame to suppress traffic to a specific MAC - that would have to go way down
into IP on all the receiving systems.
Also ISTR that pause frames are very short and don't even contain MAC
addresses.

> but your explanation makes a lot more sense.  If the EMAC never stops
> sending pause frames, then the switch's buffers will fill up, disabling
> all other devices.  If the switch does not have per-port buffers, then
> it makes sense when the buffer is full, it blocks all ports.

A switch will (probably) either have buffers for each input port, or for
each output port (or maybe both).
Output port buffers are less likely to cause grief when an output port is
running at a slower speed than the input port.

But is a switch is going to send pause frames it doesn't really matter
how the buffers are arranged. The cascade will still happen.

It would take very careful heuristics in a switch to manage pause
frames properly.

Of course, once the kernel has crashed, even multicast packets will
eventually run the MAC out of buffers.
(Unless you run on private network and manage to reinstall and reboot
while the MAC is still active and then eventually die when a receive
frame overwrites what used to be a receive buffer.)

	David
