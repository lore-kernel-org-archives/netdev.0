From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Fri, 11 May 2007 15:16:46 +0530
Message-ID: <OFBDCF5194.F60671C9-ON652572D8.0034E04E-652572D8.0035B8B9@in.ibm.com>
References: <20070510.150605.94557473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: dlstevens@us.ibm.com, gaagaan@gmail.com, johnpol@2ka.mipt.ru,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	rick.jones2@hp.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp05.au.ibm.com ([202.81.18.154]:34411 "EHLO
	ausmtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752342AbXEKJsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 05:48:05 -0400
In-Reply-To: <20070510.150605.94557473.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Very preliminary testing with 20 procs on E1000 driver gives me following
result:

skbsz        Org BW         New BW              %               Org demand
New Demand     %
32              315.98           347.48                9.97%         21090
20958               0.62%
96              833.67           882.92                5.91%         7939
9107                 -14.71

But this is test running for just 30 secs (just too short) and netperf2
(not netperf4,
which I am going to use later). Using single E1000 card cross-cable'd on
2.6.21.1
kernel on 2 CPU 2.8Ghz Xseries systems.

I will have more detailed report next week, especially once I run netperf4.
I am taking
off for the next two days, so will reply later on this thread.

Thanks,

- KK

David Miller <davem@davemloft.net> wrote on 05/11/2007 03:36:05 AM:

> From: Gagan Arneja <gaagaan@gmail.com>
> Date: Thu, 10 May 2007 14:50:19 -0700
>
> > David Miller wrote:
> >
> > > If you drop the TX lock, the number of free slots can change
> > > as another cpu gets in there queuing packets.
> >
> > Can you ever have more than one thread inside the driver? Isn't
> > xmit_lock held while we're in there?
>
> There are restrictions wrt. when the xmit_lock and the
> queue lock can be held at the same time.
>
> The devil is definitely in the details if you try to
> implemen this.  It definitely lends support for Eric D.'s
> assertion that this change will only add bugs and doing
> something simple like prefetches is proabably a safer
> route to go down.

