From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH 3/7]: [NET]: Do not check netif_running() and carrier state in ->poll()
Date: Tue, 8 Jan 2008 18:12:48 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7702CAA9F4@nekter>
References: <20080108.150735.182342472.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:17881 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752164AbYAHXN6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 18:13:58 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20080108.150735.182342472.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Got it. These new napi interface changes were introduced by someone else
and we assumed it to be correct. We will make the fix and submit.

Thanks,
Ram

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, January 08, 2008 3:08 PM
> To: Ramkrishna Vepa
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH 3/7]: [NET]: Do not check netif_running() and
carrier
> state in ->poll()
> 
> From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
> Date: Tue, 8 Jan 2008 18:01:32 -0500
> 
> > Dave,
> > Sorry, should have been clearer. When I meant "brought down" did not
> > mean close, but when a adapter reset is initiated. The
napi_disable() is
> > called only on a close. When the driver does a reset, napi_disable()
is
> > not called.
> 
> You should be doing a napi_disable() during a reset, like every
> other driver does.
> 
> It is the only reliable way to prevent the code path from running.
> 
> Otherwise, you can start resetting the device right after
> that check in the ->poll() routine, and thus still touch
> the device during the reset sequence.
> 
> In short the check is wrong, because it doesn't fully prevent
> what you want it to prevent.  Only a napi_disable() would do
> that fully for you.
