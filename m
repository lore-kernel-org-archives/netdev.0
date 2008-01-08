From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH 3/7]: [NET]: Do not check netif_running() and carrier state in ->poll()
Date: Tue, 8 Jan 2008 18:01:32 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7702CAA9E8@nekter>
References: <20080108.144731.168854521.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:43322 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753031AbYAHXCr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 18:02:47 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20080108.144731.168854521.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,
Sorry, should have been clearer. When I meant "brought down" did not
mean close, but when a adapter reset is initiated. The napi_disable() is
called only on a close. When the driver does a reset, napi_disable() is
not called. 

Ram
> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, January 08, 2008 2:48 PM
> To: Ramkrishna Vepa
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH 3/7]: [NET]: Do not check netif_running() and
carrier
> state in ->poll()
> 
> From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
> Date: Tue, 8 Jan 2008 13:17:03 -0500
> 
> > Dave,
> >
> > This change is not required as the macro, is_s2io_card_up() checks
for
> > an internal state of the adapter and not netif's state. We want to
make
> > sure that the adapter registers are not accessed when the adapter is
> > being brought down.
> 
> If the adapter is being brought down, you would have done
> a napi_disable() first and therefore never reach this code
> path.
> 
> The removal is correct, I read how your driver works.
