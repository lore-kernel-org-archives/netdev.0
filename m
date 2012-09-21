From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Fri, 21 Sep 2012 17:48:31 +0200
Message-ID: <1348242511.2669.635.camel@edumazet-glaptop>
References: <CAGK4HS_ZKKrzFh+c3WDxbkMFpDTg7ehw9ydp39k6JPFA_j1YOw@mail.gmail.com>
	 <1348119475.31352.60.camel@edumazet-glaptop> <505B4E13.5000501@hp.com>
	 <20120920.154007.1073423645697694793.davem@davemloft.net>
	 <505B773E.9070501@hp.com>  <1348172722.2669.10.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, subramanian.vijay@gmail.com,
	netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:42892 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752494Ab2IUPsh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 11:48:37 -0400
Received: by bkuw11 with SMTP id w11so898904bku.19
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2012 08:48:35 -0700 (PDT)
In-Reply-To: <1348172722.2669.10.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-20 at 22:25 +0200, Eric Dumazet wrote:
> On Thu, 2012-09-20 at 13:06 -0700, Rick Jones wrote:
> 
> > 
> > Yes, I was being too fast and loose with my wording, paying more 
> > attention to the netperf tests than the rest of it.  While loopback may 
> > be lossless, TCP retransmissions over loopback shouldn't be all *that* 
> > surprising.
> 
> Sending perfect packets (large packets) should trigger no retransmits.

By the way, with current MTU of 16436 on loopback, max packet size is
48KB (3 MSS)

Using an mtu of 65536 allows another 25% increase of bulk performance...

(and less potential reordering effects, as a packet contains one MSS
instead of three)

There is probably a reason why lo default MTU is 16436 ?
