From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: behavior of recvmmsg() on blocking sockets
Date: Mon, 29 Mar 2010 10:18:23 -0600
Message-ID: <4BB0D2CF.9040903@nortel.com>
References: <84621a61003240915p2a4ce6bbjd0c6bfb02ab05ba8@mail.gmail.com>	 <4BAA4EE4.3090900@nortel.com>	 <84621a61003241128x3afbcea1w387aeaa68c887320@mail.gmail.com>	 <4BAA69BF.3080600@nortel.com>	 <84621a61003241255i74282f53v3bb0111808895401@mail.gmail.com> <84621a61003270619p6b4fe81bi24bb1961aba77ffb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Brandon Black <blblack@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <84621a61003270619p6b4fe81bi24bb1961aba77ffb@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/27/2010 07:19 AM, Brandon Black wrote:

> I've been playing with the timeout argument to recvmmsg as well now,
> and I'm struggling to see how one would ever use it correctly with the
> current implementation.

I'd probably do something like this:

prev = current time
loop forever
	cur = current time
	timeout = max_latency - (cur - prev)
	recvmmsg(timeout)
	process all received messages
	prev = cur


Basically you determine the max latency you're willing to wait for a
packet to be handled, then subtract the amount of time you spent
processing messages from that and pass it into the recvmmsg() call as
the timeout.  That way no messages will be delayed for longer than the
max latency. (Not considering scheduling delays.)

Chris
