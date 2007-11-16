From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv4/arp.c: Fix arp reply when sender ip 0
Date: Fri, 16 Nov 2007 01:05:48 -0800 (PST)
Message-ID: <20071116.010548.94286711.davem@davemloft.net>
References: <cac0ab7d0711151340l1cc91a2dw5ebf36e166d16d7a@mail.gmail.com>
	<20071115.152813.89410917.davem@davemloft.net>
	<cac0ab7d0711160030w149c7a7s2db55ac56d0a05cc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org,
	jmorris@namei.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: the.sator@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43092
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752619AbXKPJFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2007 04:05:53 -0500
In-Reply-To: <cac0ab7d0711160030w149c7a7s2db55ac56d0a05cc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jonas Danielsson" <the.sator@gmail.com>
Date: Fri, 16 Nov 2007 09:30:11 +0100

> 2007/11/16, David Miller <davem@davemloft.net>:
> > From: "Jonas Danielsson" <the.sator@gmail.com>
> > Date: Thu, 15 Nov 2007 22:40:13 +0100
> >
> > > Is there a reason that the target hardware address isn't the target
> > > hardware address?
> >
> 
> 
> > Because of this, in cases where a choice can be made Linux will
> > advertise what is most likely to result in successful communication.
> >
> > This is likely why we are changing that target address to the one of
> > the interface actually sending back the reply rather than the zero
> > value you used.
> >
> > In fact I think this information can be useful to the sender of
> > the DAD request.
> >
> 
> There seem to be some confusion about what my patch really does. It
> does not set the hardware address to a zero value.

I knew you were talking about the IP address not the hardware
address.

> The reply from the Linux kernel in computer A, before the patch would look like:
> 
> Reply:
> Opcode: reply (0x0002)
> Sender HW: 00:AA.00:AA:00:AA
> Sender IP:   192.168.0.1
> Target HW:  00:AA:00:AA:00:AA
> Target IP:    192.168.0.1

And this is exactly a sensible response in my opinion.
