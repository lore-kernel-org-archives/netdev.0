From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net] net: solve a NAPI race
Date: Tue, 28 Feb 2017 05:04:07 -0800
Message-ID: <1488287047.9415.231.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1488032577.9415.131.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488166294.9415.172.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488205298.9415.180.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488226711.9415.204.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170227141403.714490f7@xeon-e3>
         <1488234917.9415.217.camel@edumazet-glaptop3.roam.corp.google.com>
         <063D6719AE5E284EB5DD2968C1650D6DCFE71AA0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:33034 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752602AbdB1NKd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 08:10:33 -0500
Received: by mail-pg0-f50.google.com with SMTP id 25so4938171pgy.0
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2017 05:10:32 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFE71AA0@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-02-28 at 10:14 +0000, David Laight wrote:
> From: Eric Dumazet
> > Sent: 27 February 2017 22:35
> > On Mon, 2017-02-27 at 14:14 -0800, Stephen Hemminger wrote:
> > 
> > > The original design (as Davem mentioned) was that IRQ's must be disabled
> > > during device polling. If that was true, then the race above
> > > would be impossible.
> > 
> > I would love to see an alternative patch.
> 
> Can you test for 'receive data available' after telling the NAPI
> logic that you've finished?
> You'd then need to force a reschedule.
> 
> I think your proposed patch will do a reschedule if any packet arrives
> during the receive processing, not just when one arrives right at the end.
> You might want to 'unset' the reschedule flag before each check of the
> receive ring.
> 
> I also wonder about the cost of processing the MSI-X (I guess) interrupts
> compared to the cost of posted PCIe writes to disable and/or mask the
> interrupt generation.
> Clearly you don't want to do PCIe reads.

Have you seen the mlx4 patch I provided ?

Then, I did not want to review 100+ NAPI drivers and provide patches for
them.

This generic solution is basically free. Same number of atomic
operations.

Given it took more than 2 years to even spot the bug, I have no idea how
people on netdev expect me to review all drivers. This is crazy.
