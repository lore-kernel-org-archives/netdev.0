From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Sat, 30 Aug 2008 00:43:59 +0400
Message-ID: <20080829204359.GA17515@2ka.mipt.ru>
References: <20080828072218.GI26610@one.firstfloor.org> <32566205.1357331220023286187.JavaMail.root@ouachita>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, dada1@cosmosbay.com,
	denys@visp.net.lb, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, juhlenko@akamai.com, sammy@sammy.net
To: Joe Malicki <jmalicki@metacarta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:52507 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753446AbYH2Uoh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2008 16:44:37 -0400
Content-Disposition: inline
In-Reply-To: <32566205.1357331220023286187.JavaMail.root@ouachita>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 29, 2008 at 11:21:26AM -0400, Joe Malicki (jmalicki@metacarta.com) wrote:
> > But didn't you really want a "end2end" time stamp in this case,
> > as in really at the end of all kernel/hardware queues on your side.
> 
> No.
> 
> That adds variance, and packets aren't comparable because they may
> suffer different kernel/hardware delays.
> 
> The goal is to approximate original sendtime when the application-level
> timestamps are unreliable.  The more queueing delays that can be
> taken out of the timestamp, the better.

Just a note from that one who really developed real-time audio and
video processing engines: _no_one_ really relies to the timestamps
attached to the received packet. By no one I really mean NO ONE. It is
ust wrong, broken and stupid. There are so many queues in the data
path, that it just can not be reliable by definition.

Instead sending path incapsulates packet sequence number into appropriate
packet header (like, and the most cases the only, RTP header), and
receiving path just multiplies this sequence number by the compression
rate and size of the packet. This numbers differ from design to design,
but overall approach is the same: no one really depends on the hardware
timestamp attached on the receiver, only sender's data is reliable.
If someone depends on it, it is broken and just waits for the
appropriate attack vector to inect broken data into the dataflow (such
users do not use tcp, since it "introduces unneded delays" or similar
marketing and compeltely untested things).

So this overall discussion of the timestamp option is meaningless: we
just bloody can not change it as is, since so many applications really
depend on it (even if they should not).

We can force lower resolution in terms of xtime or similar counter,
which will be default timestamp in case of some syscall (turned off by
default), but since so far no one sent a patch, this looks very subtle.

-- 
	Evgeniy Polyakov
