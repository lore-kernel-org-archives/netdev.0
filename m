From: Dan Williams <dcbw@redhat.com>
Subject: Re: Setting link down or up in software
Date: Thu, 12 Jan 2017 12:45:16 -0600
Message-ID: <1484246716.4651.5.camel@redhat.com>
References: <75bd6df2-714a-2b9b-a0e3-f5574c295377@free.fr>
         <2044a26f-cf95-ac55-6265-ac76c3ca53f6@free.fr>
         <20170112152856.GL13033@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>, Mans Rullgard <mans@mansr.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>
To: Andrew Lunn <andrew@lunn.ch>, Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34502 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750786AbdALSpT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 13:45:19 -0500
In-Reply-To: <20170112152856.GL13033@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-01-12 at 16:28 +0100, Andrew Lunn wrote:
> > Here's an example of "Link is Down" printed when I set link up:
> > 
> > At [   62.750220] I run ip link set dev eth0 down
> > Then leave the system idle for 10 minutes.
> > At [  646.263041] I run ip link set dev eth0 up
> > At [  647.364079] it prints "Link is Down"
> > At [  649.417434] it prints "Link is Up - 1Gbps/Full - flow control
> > rx/tx"
> 
> Purely a guess, but when you up the interface, it starts auto
> negotiation. That often involves resetting the PHY. If the PHY has
> already once completed autoneg, e.g. because of the boot loader, it
> will be initially UP. The reset will put it DOWN, and then once
> autoneg is complete, it will be Up again.
> 
> Pure guess. Go read the code and see if i'm write.

Historically, !IFF_UP meant the phy could be powered down or go into
some kind of low-power mode where link negotiation and communication
was unavailable.  Some drivers implemented that, some keep the PHY up
because who knows why, or because they just never got around to real
power management.

Dan
