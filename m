From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Setting link down or up in software
Date: Thu, 12 Jan 2017 16:28:56 +0100
Message-ID: <20170112152856.GL13033@lunn.ch>
References: <75bd6df2-714a-2b9b-a0e3-f5574c295377@free.fr>
 <2044a26f-cf95-ac55-6265-ac76c3ca53f6@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Mans Rullgard <mans@mansr.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>
To: Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58429 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750816AbdALP27 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 10:28:59 -0500
Content-Disposition: inline
In-Reply-To: <2044a26f-cf95-ac55-6265-ac76c3ca53f6@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Here's an example of "Link is Down" printed when I set link up:
> 
> At [   62.750220] I run ip link set dev eth0 down
> Then leave the system idle for 10 minutes.
> At [  646.263041] I run ip link set dev eth0 up
> At [  647.364079] it prints "Link is Down"
> At [  649.417434] it prints "Link is Up - 1Gbps/Full - flow control rx/tx"

Purely a guess, but when you up the interface, it starts auto
negotiation. That often involves resetting the PHY. If the PHY has
already once completed autoneg, e.g. because of the boot loader, it
will be initially UP. The reset will put it DOWN, and then once
autoneg is complete, it will be Up again.

Pure guess. Go read the code and see if i'm write.

     Andrew
