From: kuznet@ms2.inr.ac.ru
Subject: Re: packet re-ordering on SMP machines.
Date: Tue, 27 Aug 2002 17:06:30 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200208271306.RAA19164@sex.inr.ac.ru>
References: <20020827142004.C4358@wotan.suse.de>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@suse.DE (Andi Kleen)
In-Reply-To: <20020827142004.C4358@wotan.suse.de> from "Andi Kleen" at Aug 27, 2 04:45:00 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Of course. The only problem is that the clock can be non mononotonous 
> sometimes and not be in sync with gettimeofday, but at least the kernel 
> users of packet timestamps do not care.

What kernel users? Where did you find them? :-)


> The only problem is the socket option, but it is obscure enough that I 
> would not worry too much about it.

I am very sorry, but passing timestamp to user level is the only purpose
of timestamping and it _MUST_ be monotonic and synchronous to time of day,
otherwise it is completely useless.

Shortly, this timestmap must be synchronous to timeofday.

> > > - Implement lockless

You talk about this for ages. :-)


Actually, the problem is solved very easily. Deprecate SIOCGSTAMP,
and either count users of SO_TIMESTAMP and enable timestamping only
when it is required, or, alternatively, to move retrirval timestamp to socket
level.

Alexey
