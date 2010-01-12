From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bug #14925] sky2 panic under load
Date: Tue, 12 Jan 2010 08:56:34 +0000
Message-ID: <20100112085633.GB6628@ff.dom.local>
References: <20100111220753.GC3139@del.dom.local> <20100111.161419.138918787.davem@davemloft.net> <20100112075059.GA6628@ff.dom.local> <20100112.000804.186755338.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, mikem@ring3k.org, flyboy@gmail.com,
	rjw@sisk.pl, netdev@vger.kernel.org,
	Michael Breuer <mbreuer@majjas.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:42940 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752544Ab0ALI4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 03:56:43 -0500
Received: by fg-out-1718.google.com with SMTP id 19so9243172fgg.1
        for <netdev@vger.kernel.org>; Tue, 12 Jan 2010 00:56:41 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100112.000804.186755338.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 12, 2010 at 12:08:04AM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Tue, 12 Jan 2010 07:50:59 +0000
> 
> > I think, I can see similar problems e.g. in gianfar or netxen, where
> > napi_disable() is done after netif_device_detach(), especially in
> > suspend procedures (there might be less severe (than oops) effects
> > yet). IMHO, it all looks simply error prone (sometime you have to
> > know a driver well to track all possible paths to say it's really
> > safe).
> 
> Then that's an even larger bug.
> 
> Until you do napi_disable(), the device can be touched.
> 
> Asynchronous paths outside of the driver's control, even
> with interrupts disabled, can call back into the driver
> and touch the chip.
> 
> F.e. netpoll via netconsole output on another cpu
> 
> So it therefore must be done before doing the actual work of bringing
> the device down or suspending it.

Maybe I miss something, but once more: this patch mentioned by Berck
Nash has been tested by at least two users, Berck himself, and
probably even more intensively by Michael Breuer, during af_packet
debugging. Both guys acknowledged it helped, so it can't be that bad.

Jarek P.
