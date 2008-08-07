From: "Tom Herbert" <therbert@google.com>
Subject: Re: SO_REUSEPORT?
Date: Thu, 7 Aug 2008 16:05:55 -0700
Message-ID: <65634d660808071605k6301cc1aubea542595763d4e3@mail.gmail.com>
References: <65634d660808070957j12e1f93rfb577efabc771c9a@mail.gmail.com>
	 <200808072009.34891.rdenis@simphalempin.com>
	 <65634d660808071058k7eb33330tcf3c7a877b7a64d@mail.gmail.com>
	 <489B3C53.1000202@hp.com> <20080807120359.2d62880a@extreme>
	 <65634d660808071243yd7de635i7e780f526161b445@mail.gmail.com>
	 <489B578A.9030505@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Stephen Hemminger" <stephen.hemminger@vyatta.com>,
	netdev@vger.kernel.org
To: "Rick Jones" <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:43009 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753450AbYHGXGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 19:06:06 -0400
Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out3.google.com with ESMTP id m77N60Qx028632
	for <netdev@vger.kernel.org>; Fri, 8 Aug 2008 00:06:01 +0100
Received: from rv-out-0708.google.com (rvbk29.prod.google.com [10.140.87.29])
	by zps78.corp.google.com with ESMTP id m77N5u6s009443
	for <netdev@vger.kernel.org>; Thu, 7 Aug 2008 16:05:56 -0700
Received: by rv-out-0708.google.com with SMTP id k29so652801rvb.0
        for <netdev@vger.kernel.org>; Thu, 07 Aug 2008 16:05:56 -0700 (PDT)
In-Reply-To: <489B578A.9030505@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Well, if you _really_ want the load spread, you may need to use a multiqueue
> (at least inbound if not also later outbound) interface, "know" how the NIC
> will hash and then have N distinct port numbers each assigned to a LISTEN
> endpoint.  The old song and dance about making an N CPU system look as much
> like N single-CPU systems and all that...
>

Yep that's what I really want, except for the fact that I can only use
a single port for the server--  all flows could be nicely distributed
by the NIC multiqueue, but I still have the problem of how to ensure
that the accepting thread for a connection is run on the same CPU as
the interrupt and SYN processing were.

> Unless there are NICs you can "tell" where to send the interrupts, which IMO
> is preferable - I have a preference for the application/scheduler telling
> "networking" where to work rather than networking (or the NIC) telling the
> scheduler where to run a thread - the archives of either here or netnews
> will probalby pull-up stuff were I've talked about Inbound Packet Scheduling
> (IPS) vs Thread Optimized Packet Scheduling (TOPS) and limitations of
> simplistic address hashing to pick a queue/processor/whatnot :)
>

NICs are already doing steering based on tuple hash (RSS), and I think
some will allow specifying the CPU for interrupt based on RX flow.
Maybe this would address the issues of Inbound Packet Scheduling?

Thanks for the pointers on IPS and TOPS.  Out of curiosity has there
been an effort to do TOPS on Linux?  We are doing something very
similar in software RSS with a fair amount of success (I posted
patches for this a while back).

Tom
