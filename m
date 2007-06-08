From: jamal <hadi@cyberus.ca>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Fri, 08 Jun 2007 07:14:06 -0400
Message-ID: <1181301246.4063.15.camel@localhost>
References: <OFE747F0A6.D87A0584-ON652572F4.001AE91F-652572F4.001C1B29@in.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Gagan Arneja <gaagaan@gmail.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.231]:47892 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937466AbXFHLOK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2007 07:14:10 -0400
Received: by wx-out-0506.google.com with SMTP id t15so696352wxc
        for <netdev@vger.kernel.org>; Fri, 08 Jun 2007 04:14:10 -0700 (PDT)
In-Reply-To: <OFE747F0A6.D87A0584-ON652572F4.001AE91F-652572F4.001C1B29@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

KK,
On Fri, 2007-08-06 at 10:36 +0530, Krishna Kumar2 wrote:

> I will try that. Also on the receiver, I am using unmodified 2.6.21 bits.

That should be fine as long as the sender is running the patched
2.6.22-rc4

> My earlier experiments showed that even small buffers were filling the
> E1000
> slots and resulting in stop queue very often. In any case, I will also
> add 1 or 2 larger packet sizes (1K, 16K in addition to the 4K already
> there).

Thats interesting - it is possible there is transient burstiness which
fills up the ring.
My observation of your results (hence my comments): for example the
buffer size = 8B, TCP 1 process you achieve less than 70M.  That is less
than 100Kpps on average being sent out. Very very tiny - so it is
interesting that it is causing a shutdown.
Also note something else strange that it is kind of strange that
something like UDP which doesnt backoff will send out less
packets/second ;->

I could put a little hack in the e1000 driver to find exact number
number of times per run it was shutdown.

BTW, another interesting things to do is ensure that several netperfs
are running on different CPUs.


> I was planning to submit my changes on top of this patch, and since it
> includes
> a configuration option per device, it will be easy to test with and without
> this API. 

fantastic.

> When I ran after setting this config option to 0, the results
> were almost identical to the original code. I will try to post that today for
> your review/comments.

no problem.

> > Sorry, been many moons since i last played with netperf; what does
> "service
> > demand" mean?
> 
> It gives an indication of the amount of CPU cycles to send out a particular
> amount of data. Netperf provides it as us/KB. I don't know the internals of
> netperf enough to say how this is calculated.

I am hoping Rick would comment.

cheers,
jamal

