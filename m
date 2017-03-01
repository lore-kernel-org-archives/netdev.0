From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2 net] net: solve a NAPI race
Date: Wed, 1 Mar 2017 01:22:40 +0100
Message-ID: <20170301002240.GA6899@electric-eye.fr.zoreil.com>
References: <1488205298.9415.180.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170227.111944.1725806340309799464.davem@davemloft.net>
 <1488213854.9415.198.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170227.210810.197044715013755200.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
        tariqt@mellanox.com, saeedm@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:42898 "EHLO
        violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751396AbdCAAkg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 19:40:36 -0500
Content-Disposition: inline
In-Reply-To: <20170227.210810.197044715013755200.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 27 Feb 2017 08:44:14 -0800
> 
> > Any point doing a napi_schedule() not from device hard irq handler
> > is subject to the race for NIC using some kind of edge trigger
> > interrupts.
> > 
> > Since we do not provide a ndo to disable device interrupts, the
> > following can happen.
> 
> Ok, now I understand.
> 
> I think even without considering the race you are trying to solve,
> this situation is really dangerous.
> 
> I am sure that every ->poll() handler out there was written by an
> author who completely assumed that if they are executing then the
> device's interrupts for that NAPI instance are disabled.  And this is
> with very few, if any, exceptions.

Shareable pci irq used to remind author that such an assumption was
not always right. Otoh it was still manageable as long as level only
triggered irq were involved.

-- 
Ueimor
