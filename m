From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 net] net: solve a NAPI race
Date: Tue, 28 Feb 2017 17:04:13 -0800
Message-ID: <20170228170413.1c217602@xeon-e3>
References: <1488205298.9415.180.camel@edumazet-glaptop3.roam.corp.google.com>
        <20170227.111944.1725806340309799464.davem@davemloft.net>
        <1488213854.9415.198.camel@edumazet-glaptop3.roam.corp.google.com>
        <20170227.210810.197044715013755200.davem@davemloft.net>
        <20170301002240.GA6899@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
        netdev@vger.kernel.org, tariqt@mellanox.com, saeedm@mellanox.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33597 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751601AbdCAB3Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 20:29:24 -0500
Received: by mail-pf0-f171.google.com with SMTP id w189so6316929pfb.0
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2017 17:29:16 -0800 (PST)
In-Reply-To: <20170301002240.GA6899@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 1 Mar 2017 01:22:40 +0100
Francois Romieu <romieu@fr.zoreil.com> wrote:

> David Miller <davem@davemloft.net> :
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Mon, 27 Feb 2017 08:44:14 -0800
> >   
> > > Any point doing a napi_schedule() not from device hard irq handler
> > > is subject to the race for NIC using some kind of edge trigger
> > > interrupts.
> > > 
> > > Since we do not provide a ndo to disable device interrupts, the
> > > following can happen.  
> > 
> > Ok, now I understand.
> > 
> > I think even without considering the race you are trying to solve,
> > this situation is really dangerous.
> > 
> > I am sure that every ->poll() handler out there was written by an
> > author who completely assumed that if they are executing then the
> > device's interrupts for that NAPI instance are disabled.  And this is
> > with very few, if any, exceptions.  
> 
> Shareable pci irq used to remind author that such an assumption was
> not always right. Otoh it was still manageable as long as level only
> triggered irq were involved.
> 

When I had to deal with that in sky2, the best way was to have a single
NAPI poll handler shared between both ports. Works well and avoids races
in interrupt handling and enabling.
