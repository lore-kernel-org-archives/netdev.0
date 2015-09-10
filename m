From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] sctp: fix race on protocol/netns initialization
Date: Thu, 10 Sep 2015 15:03:36 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB91B0A@AcuExch.aculab.com>
References: <27f20cc781cac28bc2ce7229719748a2f6824bd8.1441827818.git.marcelo.leitner@gmail.com>
 <20150909.171600.1487892650387164045.davem@davemloft.net>
 <55F17D69.2050404@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CB9194F@AcuExch.aculab.com>
 <55F1955D.8010302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"vyasevich@gmail.com" <vyasevich@gmail.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: 'Marcelo Ricardo Leitner' <marcelo.leitner@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.194]:61181 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753511AbbIJPEt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 11:04:49 -0400
In-Reply-To: <55F1955D.8010302@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo 
> Sent: 10 September 2015 15:36
...
> > Given that the first ->create() blocks while the protocol code loads
> > it really wouldn't be right to error a subsequent ->create() because
> > the load hasn't completed.
> 
> Can't say I don't agree with you, but at the same time, there are other
> temporary errors that can happen and that the user should just retry.
> This would be just another condition in a trade off for avoiding complexity.

We do retry, but the delay messes up out test scripts :-(

> > I hold a semaphore across sock_create_kern() because of issues with sctp.
> > (Current kernels are nowhere near as bad as really old ones though.)
> 
> Oh, that's not good to hear. I'll experiment with that later, try to
> catch some bugs. :)

I mean REALLY old - like 2.6.12 (FC3).
I'm pretty sure I've seen oops as well as create failing.

We don't create enough sockets for the semaphore to be a problem.

OTOH I've a current problem with a customer using RHEL5.8 (basically 2.6.18).
They might manage to move to RHEL6 (2.6.32) - but that could take a year or two.
RH might be pulling some of the SCTP fixes, but I doubt they get priority.

	David
