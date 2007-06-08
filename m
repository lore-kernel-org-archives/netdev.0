From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Fri, 8 Jun 2007 10:36:59 +0530
Message-ID: <OFE747F0A6.D87A0584-ON652572F4.001AE91F-652572F4.001C1B29@in.ibm.com>
References: <1181218576.4064.40.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Gagan Arneja <gaagaan@gmail.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	Sridhar Samudrala <sri@us.ibm.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp06.au.ibm.com ([202.81.18.155]:52903 "EHLO
	ausmtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756305AbXFHFIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2007 01:08:17 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp06.au.ibm.com (8.13.8/8.13.8) with ESMTP id l5859Q2a8007734
	for <netdev@vger.kernel.org>; Fri, 8 Jun 2007 15:09:27 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l585Bgq6167402
	for <netdev@vger.kernel.org>; Fri, 8 Jun 2007 15:11:43 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5857vdr008395
	for <netdev@vger.kernel.org>; Fri, 8 Jun 2007 15:07:58 +1000
In-Reply-To: <1181218576.4064.40.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jamal,

> Would be nice to run three sets - but i think even one would be
> sufficiently revealing.

I will try multiple runs over the weekend. During the week, the systems
are used for other purposes too.

> I expect UDP to overwhelm the receiver. So the receiver needs a lot more
> tuning (like increased rcv socket buffer sizes to keep up, IMO).

I will try that. Also on the receiver, I am using unmodified 2.6.21 bits.

> It seems to me any runs with buffer less than 512B are unable to fill
> the pipe - so will not really benefit (will probably do with nagling).
> However, the < 512 B should show equivalent results before and after the
> changes.

My earlier experiments showed that even small buffers were filling the
E1000
slots and resulting in stop queue very often. In any case, I will also
add 1 or 2 larger packet sizes (1K, 16K in addition to the 4K already
there).

> You can try to turn off _BTX feature in the driver and see if they are
> the same. If they are not, then the suspect change will be easy to find.

I was planning to submit my changes on top of this patch, and since it
includes
a configuration option per device, it will be easy to test with and without
this API. When I ran after setting this config option to 0, the results
were
almost identical to the original code. I will try to post that today for
your
review/comments.

> Sorry, been many moons since i last played with netperf; what does
"service
> demand" mean?

It gives an indication of the amount of CPU cycles to send out a particular
amount of data. Netperf provides it as us/KB. I don't know the internals of
netperf enough to say how this is calculated.

thanks,

- KK

