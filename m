From: Marian =?utf-8?B?xI51cmtvdmnEjQ==?= <md@bts.sk>
Subject: Re: TCP rx window autotuning harmful at LAN context
Date: Wed, 11 Mar 2009 09:29:20 +0100
Message-ID: <20090311082920.GA20543@bts.sk>
References: <20090310114606.GA84964@bts.sk> <1e41a3230903100823h5d5768d9wb9f36eb294840814@mail.gmail.com> <20090310160040.GA93054@bts.sk> <20090310.091816.178102814.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: johnwheffner@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from saus.bts.sk ([194.160.23.4]:54025 "EHLO saus.bts.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750947AbZCKI3Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2009 04:29:24 -0400
Content-Disposition: inline
In-Reply-To: <20090310.091816.178102814.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 10, 2009 at 09:18:16AM -0700, David Miller wrote:
> There are both global system-wide and socket local limits to how much
> memory can be consumed by TCP receive data.  If things get beyond the
> configured limits, we back off.  You could modify those if you
> personally wish.
> 
> It's really good that you brought up this issue.
> 
> And it's really good that you've explained your own personal
> workaround for this issue.

Beg your pardon - "personal" ?! Is our university the only place where
people use Linux on workstations with 100 Mbps ethernet connection?
Isn't the stock kernel supposed to work decently for them - or should
they all become TCP experts and fiddle with various parameters in order
not to cause harm to other applications or the whole LAN just by starting
a single bulk transfer?

For the last time: setting TCP window to BDP is well-known and generally
accepted practice. Autotuning does NOT respect it, and for 100 Mpbs 
connections at LAN context it might set the rx window somewhere between
100*BDP and 300*BDP. Since the BDP formula obviously applies also in 
reverse direction, i.e.

delay=window/bandwith

setting insanely huge window results in insanely increased LAN latencies
(upto buffer limits). Is this really something noone cares about ?! 
