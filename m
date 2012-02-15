From: Neal Cardwell <ncardwell@google.com>
Subject: Re: Re: Re: Re: Re: Re: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Wed, 15 Feb 2012 14:44:10 -0500
Message-ID: <CADVnQy=UOvC06TBOE7d7WvuKm1Tdkzu7M4dfvm6VRcRJaDMyLw@mail.gmail.com>
References: <8633039.fHPLx6GNq3@localhost.localdomain>
	<4249109.nLB9JCi9YF@localhost.localdomain>
	<1329313785.2437.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<2687521.3ztN17SHUf@localhost.localdomain>
	<1329318481.2437.57.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Netdev <netdev@vger.kernel.org>, alekcejk@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:43081 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754987Ab2BOToL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 14:44:11 -0500
Received: by qadc10 with SMTP id c10so3505408qad.19
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 11:44:10 -0800 (PST)
In-Reply-To: <1329318481.2437.57.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks, Eric, for the clarification.

I am still intrigued by these aspects of the issue:

> Also I want to pay attention that limited speed stays constant - always
> 5.5 MB/s with straight line on traffic plotter as if was network bandwidth shaping.
> With 3.1 kernels this never happens - speed can vary in some ranges
> but at maximum it is about 11 MB/s, no limitations such as 5.5 MB/s.
...

> But I can say that probably there is really 100Mb/s
> with Full duplex because as I wrote in first mail
> there is some servers which have almost the same
> speed with 3.2.3 kernel as with 3.1.10.
> They are mostly located geographically close to me
> (maybe there are other servers, not close, but I not found such one).
> Here example of such server ftp.linux.kiev.ua,
> download speed 11,1 Megabytes/s with both kernels.
...

To me, these symptoms smell like a receiver window issue that is
capping bandwidth at some receive_window/RTT value:

1) when there is a problem bandwidth is a "straight line" instead of
typically variable TCP performance

2) when there is a problem, it is with geographically remote
(high-RTT) sites and not local sites

3) the problem only shows up when certain versions of the kernel act
as a receiver

I would be intrigued to see the following pieces of info for a slow
transfer (from a geographically distant server) with the problematic
3.2 kernel:

- tcpdump of first 300 or so packets to see SYN/SYNACK and RTT

- tcpdump of last 300 or so packets, to see the steady-state dynamics
  with receiver window and packet inter-arrival times

- summary of overall throughput wget sees

(I apologize if this is already in the thread somewhere... there are
now a lot of traces in the thread and it's hard to scan them all...
:-)

neal
