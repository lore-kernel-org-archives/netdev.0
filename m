From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: How does vlan driver pass vlan info to the h/w ethernet driver
Date: Mon, 1 May 2017 17:02:05 +0200
Message-ID: <20170501150205.GC1285@lunn.ch>
References: <CABM+yxkwQ1Oiw9p0tehLYyNgh6Qj=+1KKNk4hy35vz00DveyGA@mail.gmail.com>
 <CABM+yxkiOpOs5b5MM6MD4woz5R2-4_gf=t=8THXb3p=wuwTtXg@mail.gmail.com>
 <20170501143703.GA1285@lunn.ch>
 <CABM+yxmdJD2k1kA+fY9Yva24oB8BuDDhS-FQdY2EJM1ghf6xWw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: carl h <heyen2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46791 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S940197AbdEAPj4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 1 May 2017 11:39:56 -0400
Content-Disposition: inline
In-Reply-To: <CABM+yxmdJD2k1kA+fY9Yva24oB8BuDDhS-FQdY2EJM1ghf6xWw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 01, 2017 at 10:52:17AM -0400, carl h wrote:
> The Ethernet hardware *is* a 2 port switch in a phone which does support
> vlan tag insertion in the switch and driver. The driver is third party which
> I'm trying to get working with vlans.

> But i can't see how the vlan info propagates down to the switch driver.

How are you adding the vlan?

bridge vlan add dev port0 vid 42 self

That should call __vlan_add(), which calls __vlan_vid_add() which uses
switchdev to push the VLAN down into the hardware.

       Andrew
