From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/5] soreuseport: infrastructure
Date: Wed, 16 Jan 2013 11:13:06 -0800
Message-ID: <1358363586.32167.17.camel@edumazet-glaptop>
References: <alpine.DEB.2.00.1301141152130.3433@pokey.mtv.corp.google.com>
	 <20130115075323.64b2fdc7@nehalam.linuxnetplumber.net>
	 <1358266444.8744.5892.camel@edumazet-glaptop>
	 <CA+mtBx9UqyM-wTmX_ojNdH=oQO28i_4aV_z5mz1OiKJBzRRNnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, davem@davemloft.net,
	netdev@markandruth.co.uk
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:56993 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752589Ab3APTNL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 14:13:11 -0500
Received: by mail-pa0-f54.google.com with SMTP id bi5so960766pad.27
        for <netdev@vger.kernel.org>; Wed, 16 Jan 2013 11:13:10 -0800 (PST)
In-Reply-To: <CA+mtBx9UqyM-wTmX_ojNdH=oQO28i_4aV_z5mz1OiKJBzRRNnw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-16 at 10:37 -0800, Tom Herbert wrote:
> > Ideally, we should chose a target given by the current CPU number, in
> > case SYN messages are spread on all cpus or a set of cpus.
> >
> It is an ideal, but I don't readily see a practical way to do this
> given the available information, the fact that number of sockets
> created is up to the application, and the fact that there is no fixed
> binding of a socket to CPU.
> 
> Consider the simple "cpu % num" algorithm in packet fanout.  Suppose
> is a 16 CPU system, and RX queues for the NIC are processed on CPUS
> 0,3,7,11 and user creates 4 sockets.  In this configuration, on the
> first socket would ever be selected!

Sure, any hand coded 'optimization' should be correctly done.

On a 16 cpus system, I would create 16 queues, if we stick to the "cpu %
nr_queues" simple selection.

If some queues are never used, thats not a big deal, unless you have a
crazy spin polling of the queues. A blocked thread consumes almost
nothing.

It would be a rather straightforward patch to add mask capability to
af_packet (a la rps_cpus ), if we really wanted 4 queues, served by cpus
0,3,7,11 but I don't think there is an urgent need.

Another way would be to let user land to declare a preferred cpu for the
queue, even if not related to process scheduler affinity.

Anyway, this can be addressed later, in followup patches.
