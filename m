From: John Heffner <jheffner@psc.edu>
Subject: Re: tcp bw in 2.6
Date: Tue, 02 Oct 2007 14:29:03 -0400
Message-ID: <47028DEF.5070009@psc.edu>
References: <20071002005917.GB5480@bitmover.com> <E1IcfN0-0007tt-00@gondolin.me.apana.org.au> <20071002150935.GC17418@bitmover.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: lm@bitmover.com, Herbert Xu <herbert@gondor.apana.org.au>,
	torvalds@linux-foundation.org, davem@davemloft.net,
	wscott@bitmover.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:62962 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754022AbXJBS3V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 14:29:21 -0400
In-Reply-To: <20071002150935.GC17418@bitmover.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Larry McVoy wrote:
> On Tue, Oct 02, 2007 at 06:52:54PM +0800, Herbert Xu wrote:
>>> One of my clients also has gigabit so I played around with just that
>>> one and it (itanium running hpux w/ broadcom gigabit) can push the load
>>> as well.  One weird thing is that it is dependent on the direction the
>>> data is flowing.  If the hp is sending then I get 46MB/sec, if linux is
>>> sending then I get 18MB/sec.  Weird.  Linux is debian, running 
>> First of all check the CPU load on both sides to see if either
>> of them is saturating.  If the CPU's fine then look at the tcpdump
>> output to see if both receivers are using the same window settings.
> 
> tcpdump is a good idea, take a look at this.  The window starts out
> at 46 and never opens up in my test case, but in the rsh case it 
> starts out the same but does open up.  Ideas?

(Binary tcpdumps are always better than ascii.)

The window on the sender (linux box) starts at 46.  It doesn't open up, 
but it's not receiving data so it doesn't matter, and you don't expect 
it to.  The HP box always announces a window of 32768.

Looks like you have TSO enabled.  Does it behave differently if it's 
disabled?  I think Rick Jones is on to something with the HP ack 
avoidance.  Looks like a pretty low ack ratio, and it might not be 
interacting well with TSO, especially at such a small window size.

   -John
