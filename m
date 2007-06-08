From: jamal <hadi@cyberus.ca>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Fri, 08 Jun 2007 09:07:47 -0400
Message-ID: <1181308067.4063.120.camel@localhost>
References: <OFB311484E.057E34E9-ON652572F3.001D5838-652572F3.0022766D@in.ibm.com>
	 <1181216629.4064.22.camel@localhost> <20070607161335.GA4987@2ka.mipt.ru>
	 <1181254996.4071.27.camel@localhost> <20070608083807.GB11488@2ka.mipt.ru>
	 <1181302267.4063.33.camel@localhost>  <20070608120904.GA19011@2ka.mipt.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Gagan Arneja <gaagaan@gmail.com>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.229]:43946 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967479AbXFHNHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2007 09:07:51 -0400
Received: by wx-out-0506.google.com with SMTP id t15so722471wxc
        for <netdev@vger.kernel.org>; Fri, 08 Jun 2007 06:07:50 -0700 (PDT)
In-Reply-To: <20070608120904.GA19011@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-08-06 at 16:09 +0400, Evgeniy Polyakov wrote:
> On Fri, Jun 08, 2007 at 07:31:07AM -0400, jamal (hadi@cyberus.ca) wrote:


> But lock is still being hold - or there was no intention to reduce lock
> usage? As far as I read Krishna's mail, lock usage was not an issue, so
> that hunk probably should be dropped from the analysis.

With post 2.6.18 that atomic bit guarantees only one CPU will enter tx
path. The lock is only necessary to protect shared resources between tx
and rx (which could be simultenously be entered by two CPUs) such as tx
ring. Refer to some other thread talking about a possible bug with e1000
in this area. So maybe e1000 is not a good example in this sense. But
look at tg3.

> > > Without lock that would be wrong - it accesses hardware.
> > 
> > We are achieving the goal of only a single CPU entering that path. Are
> > you saying that is not good enough?
> 
> Then why essentially the same code (current batch_xmit callback)
> previously was always called with disabled interrupts? Aren't there
> some watchdog/link/poll/whatever issues present?

not in the e1000 as it stands today.


> Something, that anyone can understand :)
> For example /proc stats, although it is not very accurate, but it is
> really usable parameter from userspace point ov view.

which /proc stats?


> Btw, what is the size of the packet in pktgen in your tests? Likely it
> is small, since result is that good. That can explain alot.

There is a per-packet cost involved in that code path. So the more
packets/second you can generate the more intensely you can test that
path. I believe you will achieve overall better results with large
packets.

cheers,
jamal


