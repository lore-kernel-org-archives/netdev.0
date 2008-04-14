From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 1/3] Introduce the net_device_ops structure.
Date: Sun, 13 Apr 2008 21:20:21 -0700 (PDT)
Message-ID: <20080413.212021.226316980.davem@davemloft.net>
References: <47F636EC.5070506@openvz.org>
	<20080404081458.197f58ba@extreme>
	<47F64F4F.2020006@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, xemul@openvz.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35231
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750817AbYDNEUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 00:20:20 -0400
In-Reply-To: <47F64F4F.2020006@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 04 Apr 2008 17:54:55 +0200

> Stephen Hemminger wrote:
> > On Fri, 04 Apr 2008 18:10:52 +0400
> > Pavel Emelyanov <xemul@openvz.org> wrote:
> > 
> >> And fill it with copied from net_device.
> >>
> >> Also make newly created devices be assigned to the 
> >> (currently empty) nd_default_ops.
> >>
> >> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> > 
> > Thanks, I started this a while back but never got to the bottom.
> > Please use const where possible (on dev->nd_ops) and in devices.
> 
> 
> It might make sense to keep hard_start_xmit and hard_header
> in struct net_device since VLAN and Bonding overload them.

I echo the sentiments of Stephen (use const as much as possible)
and Patrick here.

In particular what Patrick is mentioning deserves special emphasis.

There are so many weird cases that take an existing device and then
overload one of the method pointers arbitrarily.  And I know this is
not at all limited to hard_start_xmit and hard_header.

It may therefore be very difficult to get things all the way over to
nd_ops except for a very small number pointers.  And unfortunately, if
this cannot be overcome, it limits the usefullness of the change. :-/

I encourage this work, nonetheless.
