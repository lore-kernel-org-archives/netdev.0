From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 16/16] sfc: Don't receive packets when the napi budget == 0
Date: Sat, 15 Mar 2014 12:25:06 -0700
Message-ID: <874n2znu25.fsf@xmission.com>
References: <871ty41dps.fsf_-_@xmission.com> <87lhwcw9j9.fsf_-_@xmission.com>
	<1394897014.15764.26.camel@deadeye.wl.decadent.org.uk>
	<20140315.122912.1621610280186900725.davem@davemloft.net>
	<1394904231.15764.34.camel@deadeye.wl.decadent.org.uk>
	<1394909693.9668.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:45098 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900AbaCOTZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Mar 2014 15:25:15 -0400
In-Reply-To: <1394909693.9668.6.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Sat, 15 Mar 2014 11:54:53 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Sat, 2014-03-15 at 17:23 +0000, Ben Hutchings wrote:
>
>> The Solarflare hardware provides generic event queues for RX and TX
>> completions, link changes, errors, etc.  The driver can't process TX
>> completions without going through all the other events mixed in with
>> them.
>> 
>
> ndo_poll_controller() could process all events, and queue incoming
> packets through netif_rx().
>
> Nobody cares about performance in this path.

I made this change so that we don't process rx packets in hard irq
context and cause things to break, and I made the most minimal most
obvious change I could.

queueing incoming packets with trough netif_rx sounds elegant.

The practical challenge is that there might be napi bottom halves
already scheduled to run before ndo_poll_controller is called so even
if ndo_poll_controller processes all of the events and calls netif_rx
to deal with the incoming packets the napi bottom halves will have to
still not process the queues when they are called.

Eric
