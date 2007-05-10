From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 20:52:12 +0530
Message-ID: <OF305F038C.A48D4C37-ON652572D7.00538ECA-652572D7.00546E39@in.ibm.com>
References: <20070510150833.GB24898@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:49629 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739AbXEJPWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 11:22:36 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l4AFgICr318352
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 01:42:18 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4AFQ46u176150
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 01:26:04 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4AFMW4G029623
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 01:22:33 +1000
In-Reply-To: <20070510150833.GB24898@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Evgeniy,

Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote on 05/10/2007 08:38:33 PM:

> On Thu, May 10, 2007 at 08:23:51PM +0530, Krishna Kumar
(krkumar2@in.ibm.com) wrote:
> > The reason to implement the same was to speed up IPoIB driver. But
> > before doing that, a proof of concept for E1000/AMSO drivers was
> > considered (as most of the code is generic) before implementing for
> > IPoIB. I do not have test results at this time but I am working on it.
> >
> > Please let me know if this approach is acceptable, or any suggestions.
>
> Doesn't it looks exactly like GSO/TSO/LRO stuff implemented already?

It is the reverse - GSO will segment one super-packet just before calling
the driver so that the stack is traversed only once. In my case, I am
trying to send out multiple skbs, possibly small packets, in one shot.
GSO will not help for small packets.

> Btw, main CPU limiting factor here is syscall overhead (userspace
protocol
> processing with 1500 MTU allows to reduce CPU usage and increase
> performance for 128 bytes packets sending/receiving total of 10 times).

I will test this also. But I was curious to see if without any changes to
applications, I can get better performance by linking packets and sending
it once to the driver.

What is your opinion ?

thanks,

- KK

>
> > Thanks,
> >
> > - KK
>
> --
>    Evgeniy Polyakov

