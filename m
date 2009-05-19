From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Tue, 19 May 2009 11:18:57 +0000
Message-ID: <20090519111857.GC5521@ff.dom.local>
References: <20090517201528.GA8552@ami.dom.local> <20090518190541.GA3047@ami.dom.local> <298f5c050905190355r1594b51ex7a7f3d452cc9c059@mail.gmail.com> <200905191404.50464.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Antonio Almeida <vexwek@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net,
	devik@cdi.cz, Eric Dumazet <dada1@cosmosbay.com>
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f123.google.com ([209.85.216.123]:49089 "EHLO
	mail-px0-f123.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752108AbZESLTF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 07:19:05 -0400
Received: by pxi29 with SMTP id 29so2372889pxi.33
        for <netdev@vger.kernel.org>; Tue, 19 May 2009 04:19:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200905191404.50464.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2009 at 02:04:50PM +0300, Denys Fedoryschenko wrote:
> On Tuesday 19 May 2009 13:55:43 Antonio Almeida wrote:
> > Doesn't seem to make any diference seting HTB_HYSTERESIS to 0. Here're
> > the values using #define HTB_HYSTERESIS 0
> >
> > 800 bytes:
> > class htb 1:108 parent 1:10 leaf 108: prio 7 quantum 1514 rate
> > 555000Kbit ceil 555000Kbit burst 70901b/8 mpu 0b overhead 0b cburst
> > 70901b/8 mpu 0b overhead 0b level 0
> >  Sent 9773257752 bytes 12277962 pkt (dropped 6292541, overlimits 0 requeues
> > 0) rate 621796Kbit 97644pps backlog 0b 127p requeues 0
> >  lended: 12277835 borrowed: 0 giants: 0
> >  tokens: -7 ctokens: -7
> 6292541 dropped from 12277962 pkt, means 51% dropped. Maybe something fishy 
> here?
> 
> Can you try instead of SFQ - BFIFO? For 100ms buffer, 550Mbit/s it will be 
> ~6875000 bytes bfifo.
> 
> It is by the way too short, IMHO, for this bandwidth, 127 packets is not 
> enough. 127 packets with 800 bytes can buffer 1 second for 812Kbit/s only, 
> and for 550Mbit/s it will buffer data for ~2ms only.
> 

Sure, if the queue is too short we could have a problem with reaching
the expected rate; but here it's all backwards - it could actually
"help" with the stats. ;-)

Jarek P.
