From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: IPv6-UDP 0x0000 checksum
Date: Thu, 26 Jan 2017 14:49:06 +0100
Message-ID: <1485438546.14760.7.camel@sipsolutions.net>
References: <1485437276.14760.3.camel@sipsolutions.net>
         <1485438299.5145.117.camel@edumazet-glaptop3.roam.corp.google.com>
         (sfid-20170126_144502_343976_16232A6D)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        linux-wireless <linux-wireless@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:49960 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751670AbdAZNtK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Jan 2017 08:49:10 -0500
In-Reply-To: <1485438299.5145.117.camel@edumazet-glaptop3.roam.corp.google.com> (sfid-20170126_144502_343976_16232A6D)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-01-26 at 05:44 -0800, Eric Dumazet wrote:
> On Thu, 2017-01-26 at 14:27 +0100, Johannes Berg wrote:
> > Hi,
> > 
> > It looks like right now we may have a hardware bug and accept
> > 0x0000 as
> > valid, when the outcome of the calculation is 0xffff.
> > 
> > What do you think we should do about this?
> > 
> > We could ignore the issue entirely, since 0 wasn't ever supposed to
> > be
> > sent anyway - but then we don't drop frames that we should drop. I
> > didn't manage to find the code in the IPv6/UDP stack that even does
> > that, but I assume it's there somewhere.
> > 
> > Alternatively, we could parse the packet to find the checksum
> > inside,
> > and if it's 0 then don't report CHECKSUM_UNNECESSARY, but that
> > seems
> > rather expensive/difficult due to the IPv6 variable header and all
> > that. If we wanted to go this route, are there any helper functions
> > for
> > this?
> > 
> > Unfortunately, in the current devices, we neither have a complete
> > indication that the packet was even UDP-IPv6, nor do we have the
> > raw
> > csum or anything like that. I think they're adding that to the next
> > hardware spin, but we probably need to address this issue now.

> Is this a xmit or rcv problem ?

Oops, sorry - receive. We can only indicate "CHECKSUM_UNNECESSARY",
nothing more advanced right now, but right now we'd indicate that if
the packet had 0x0000 in the checksum field, but should've had 0xffff.

On TX I believe we actually do in HW exactly what your patch just did.

johannes
