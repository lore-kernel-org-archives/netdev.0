From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 0/9] net: dsa: define port types
Date: Fri, 27 Oct 2017 09:44:58 -0400
Message-ID: <87po98r9gl.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <833b871f-e9d4-3d3e-70d5-8aaa19b8f045@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Egil Hjelmeland <privat@egil-hjelmeland.no>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:47002 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752430AbdJ0NpC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 09:45:02 -0400
In-Reply-To: <833b871f-e9d4-3d3e-70d5-8aaa19b8f045@egil-hjelmeland.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Egil,

Egil Hjelmeland <privat@egil-hjelmeland.no> writes:

>  > The DSA code currently has 3 bitmaps in the dsa_switch structure:
>  > cpu_port_mask, dsa_port_mask and enabled_port_mask.
>
>
> First I must apologize to everybody for not replying in-thread. Problem
> is that I was not subscribed to netdev. But now I am, so I promise it
> will not happen again :-)
>
> So to the point. I think DSA need to keep track of multicast
> memberships. As it is now, dsa_switch_mdb_add() include
> the CPU/DSA port(s) in the multicast. But  multicast is never
> removed from the CPU/DSA port(s).

We don't have support for this yet, but we do need to be able to remove
multicast from CPU port, if your linux processing is not interested
about a given slave multicast traffic.

> One option could be that DSA remember mulitcast memberships as bitmaps
> of ports. Then it could be handy to have the CPU and DSA ports as
> bitmaps too.
>
> It might not fall out that way in the end. But anyway, my suggestion is:
> Do patch 1 - 6, which isolates the drivers from the internal structure
> of dsa. But hold on to 7 - 9 until there is a plan for better multicast
> handling in DSA.

No. There is no need to have such bitmaps in dsa_switch. The port type
is a static information which belongs in dsa_port as an enum. For
multicast we'll see what is more handy, but caching can make things more
complex. Until then if we do need bitmaps, we'll provide helpers such as
dsa_user_ports. In a next iteration we'll provide better helpers taking
an unsigned long * as parameter so that we use the bitmap API and
finally get rid of the fixed length data type.


Thanks,

        Vivien
