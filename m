From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] IP_GRE: Linearize skb before csum.
Date: Tue, 22 Jan 2013 21:02:53 -0800
Message-ID: <1358917373.12374.707.camel@edumazet-glaptop>
References: <20130122.194143.1205292712415183747.davem@davemloft.net>
	 <1358903293.12374.492.camel@edumazet-glaptop>
	 <20130122.204629.607263597214211092.davem@davemloft.net>
	 <20130122.232235.643904201225800004.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, pshelar@nicira.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:46128 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750845Ab3AWFC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 00:02:56 -0500
Received: by mail-pb0-f48.google.com with SMTP id wy12so3080405pbc.7
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 21:02:56 -0800 (PST)
In-Reply-To: <20130122.232235.643904201225800004.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-22 at 23:22 -0500, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 22 Jan 2013 20:46:29 -0500 (EST)
> 
> > We can't emit bogus checksums on the wire when this is completely
> > under our control.
> 
> BTW consider a legitimate use case where an application has a shared
> memory page between threads that keeps track of statistic counters,
> and it uses sendfile() over an fd backing that mmap()'d area to
> send the statistics out remotely over TCP.
> 
> That's completely legitimate.
> 
> As is an application constantly overwriting a page in the filesystem
> page cache, and another app doing sendfile() over TCP from that
> area.
> 
> In such a situation everyone of your magic retransmits will have a
> bad checksum too.
> 
> You can't say that this behavior is anything other than broken, and
> I don't want to be responsible for a system that's doing broken
> things like that.
> 
> If your GSO over GRE tunnels stuff fundamentally depends upon this
> magic retransmit fantasy working, then yes we have to disable it
> completely.
> --

But then GSO should be disabled right now, GRE or not.

We have a generic problem.

GSO was a bad idea from the very beginning, if you want
such use case. 
