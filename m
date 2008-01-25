From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH 2.6.25 1/1]S2io: Multiqueue network device support implementation
Date: Thu, 24 Jan 2008 22:19:50 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7702E713B2@nekter>
References: <20080123.233006.124819204.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>,
	<netdev@vger.kernel.org>, <jeff@garzik.org>,
	"support" <support@neterion.com>
To: "David Miller" <davem@davemloft.net>, <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:46844 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752002AbYAYDVW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 22:21:22 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20080123.233006.124819204.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: netdev-owner@vger.kernel.org
[mailto:netdev-owner@vger.kernel.org]
> On Behalf Of David Miller
> Sent: Wednesday, January 23, 2008 11:30 PM
> 
> From: Andi Kleen <andi@firstfloor.org>
> Date: Thu, 24 Jan 2008 08:25:49 +0100
> 
> > > have done away with handling tx completion in the interrupt
handler,
> and
> > > are instead handling them in the context of the transmit. The slow
> path,
> > > straggling transmit completions will be handled in the timer
context.
> >
> > Ok -- hopefully you don't have bad corner cases from this when the
pipe
> > is not fully filled and then causing longer latencies on completion.
> > Old NAPI sometimes suffered from such problems.
> 
> BTW, such a TX completion timer will stall TCP sockets when the TX
> queue of the device is partially filled and then sending stops.
> 
> TX ring SKB liberation really must be done in a very small finite
> amount of time in order to avoid this problem properly.
> 
> Deferring it to HZ granular timers doesn't give a quick enough
> response, especially at high packet rates.
[Ram] We could add a lower granular tx completion interrupt instead, to
handle all the transmit fifos. But this will be a fall back in the event
the completions do not happen in the context of the transmit.

Ram
