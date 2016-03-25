From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Fri, 25 Mar 2016 09:53:38 +0100
Message-ID: <20160325085338.GB8655@1wt.eu>
References: <20160324165047.GA7585@1wt.eu>
 <1458838897.12033.10.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALx6S36Ej1es8qFi2Q3=199f+rmG=Za02N5ZBWT5DCRqrBEWvQ@mail.gmail.com>
 <56F42A00.7050002@iogearbox.net>
 <CAKQ1sVP_bbGYnVW=9WDnuzJ7qcC1xrM3qmeYFk-c3fi696F5-g@mail.gmail.com>
 <1458859788.6473.2.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKQ1sVPJoaaf1gRfgYPRygfMFVqk08Q0K74wn6kLHV+vy=8w1w@mail.gmail.com>
 <CALx6S37uZah89sNgH9wuD1J+_WEhd34Z5zmrnG8Qp-AQ7Ew=Jg@mail.gmail.com>
 <20160325052819.GA8548@1wt.eu>
 <1458888581.6473.30.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>,
	Yann Ylavic <ylavic.dev@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Tolga Ceylan <tolga.ceylan@gmail.com>,
	Craig Gallek <cgallek@google.com>,
	Josh Snyder <josh@code406.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:32958 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750797AbcCYIyD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Mar 2016 04:54:03 -0400
Content-Disposition: inline
In-Reply-To: <1458888581.6473.30.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Thu, Mar 24, 2016 at 11:49:41PM -0700, Eric Dumazet wrote:
> Everything is possible, but do not complain because BPF went in the
> kernel before your changes.

Don't get me wrong, I'm not complaining, I'm more asking for help to
try to elaborate the alternate solution. I understood well what my
proposal did because it was pretty straightforward, and the new one
I'll have to do is of an immense complexity for me by now, since it
will require learning a new language and finding doc on how all this
works together. But as I said I'm totally sold to the benefits it can
provide for large scale deployments and I'm well aware of the ugly
socket scan there was in the previous one.

> Just rework your patch.
> 
> Supporting multiple SO_REUSEPORT groups on the same port should not be
> too hard really. Making sure BPF still work for them is feasible.
> 
> But the semantic of the socket option would be really different.

I don't care much about the socket options themselves as long as I can
continue to support seamless reloads. I could even get rid of SO_REUSEPORT
on Linux to use something else instead if I have a reliable way to detect
that the alternative will work.

> You need to not control an individual listener, but a group of listener.
> 
> Your dying haproxy would issue a single system call to tell the kernel :
> My SO_REUSEPORT group should not accept new SYN packets, so that the new
> haproxy can setup a working new SO_REUSEPORT group.

Normally it's the other way around :-) The new process first grabs the
socket, there's a tiny window where both are attached, and only then the
old process leaves. That's the only way to ensure there's no loss nor
added latency in the processing.

If you could share a pointer to some good starter documentation for this,
I would appreciate it. I really have no idea where to start from and the
only elements I found on the net didn't give a single hint regarding all
this :-/

Thanks,
Willy
