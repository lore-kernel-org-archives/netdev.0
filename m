From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 4.4-rc7 failure report
Date: Wed, 30 Dec 2015 14:08:46 -0500
Message-ID: <1451502526.8255.48.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5683A630.2070401@iogearbox.net>
	 <20151230151123.GB4874@codemonkey.org.uk>
	 <1451494525.8255.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151230.125003.301825767708169401.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davej@codemonkey.org.uk, daniel@iogearbox.net,
	alexei.starovoitov@gmail.com, dledford@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:36416 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754844AbbL3TIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 14:08:48 -0500
Received: by mail-pf0-f175.google.com with SMTP id 65so100799460pff.3
        for <netdev@vger.kernel.org>; Wed, 30 Dec 2015 11:08:48 -0800 (PST)
In-Reply-To: <20151230.125003.301825767708169401.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-12-30 at 12:50 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 30 Dec 2015 11:55:25 -0500
> 
> > On Wed, 2015-12-30 at 10:11 -0500, Dave Jones wrote:
> >> On Wed, Dec 30, 2015 at 10:38:56AM +0100, Daniel Borkmann wrote:
> >> 
> >>  > Given that this drop doesn't strictly need to be caused by filter code,
> >>  > it would be nice if you could pin the location down where the packet gets
> >>  > dropped exactly. Perhaps dropwatch or perf with '-e skb:kfree_skb -a -g
> >>  > dhclient <iface>', etc could help to get a first overview to dig into
> >>  > details then.
> >> 
> >> Wild stab in the dark, but..
> >> Could this bug be another symptom fixed by http://article.gmane.org/gmane.linux.network/392885 ?
> > 
> > dhclient does not use async io
> 
> But the bug causes requests to "LOOK" like async I/O, right?


This is not how I understood the bug.

By having a bit set (because we lacked a clear of wq->flags), we have :

sock_wake_async()
...
case SOCK_WAKE_WAITD:
	if (test_bit(SOCKWQ_ASYNC_WAITDATA, &wq->flags))
		break; 

So we never call kill_fasync()
