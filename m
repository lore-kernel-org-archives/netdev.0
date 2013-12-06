From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: auto corking
Date: Fri, 06 Dec 2013 09:46:16 -0800
Message-ID: <1386351976.30495.266.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386311765.30495.246.camel@edumazet-glaptop2.roam.corp.google.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7467@saturn3.aculab.com>
	 <52A1F603.2030208@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:36109 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758143Ab3LFRqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 12:46:20 -0500
Received: by mail-pd0-f182.google.com with SMTP id v10so1397199pde.27
        for <netdev@vger.kernel.org>; Fri, 06 Dec 2013 09:46:19 -0800 (PST)
In-Reply-To: <52A1F603.2030208@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-06 at 08:06 -0800, Rick Jones wrote:
> On 12/06/2013 02:30 AM, David Laight wrote:
> >> From: Eric Dumazet <edumazet@google.com>
> >>
> >> With the introduction of TCP Small Queues, TSO auto sizing, and TCP
> >> pacing, we can implement Automatic Corking in the kernel, to help
> >> applications doing small write()/sendmsg() to TCP sockets.
> >
> > Presumably this has the greatest effect on connections with Nagle
> > disabled?
> 
> I was wondering why Nagle didn't catch these things as well.  The 
> netperf command line Eric provided though didn't include the 
> test-specific -D option that would have disabled Nagle.  At least not 
> unless the "super_netperf" wrapper was adding it.
> 
> So, why doesn't Nagle catch what is presumably a sub-MSS send while 
> there is data outstanding on the connection?

super_netperf do not add any option.

Note the netperf results do no really show the improvements of this
patch. It's a side effect of the short cut.

You kind of need a TCP_RR workload, but splitting the request into small
chunks.

Well written applications use TCP_CORK or MSG_MORE, but unfortunately
many applications are not well written.

(Or people tried TCP_CORK in the past and got bitten by various bugs in
TCP stack that we fixed only last year)
