From: jamal <hadi@cyberus.ca>
Subject: Re: Luca Deri's paper: Improving Passive Packet Capture: Beyond
	Device Polling
Date: 06 Apr 2004 10:18:46 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1081261126.1047.6.camel@jzny.localdomain>
References: <20040330142354.GA17671@outblaze.com>
	 <1081033332.2037.61.camel@jzny.localdomain>  <c4rvvv$dbf$1@sea.gmane.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Luca Deri <deri@ntop.org>,
        Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jason Lunz <lunz@falooley.org>
In-Reply-To: <c4rvvv$dbf$1@sea.gmane.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-04-05 at 12:03, Jason Lunz wrote:

> Yes, I read the paper (but not his code). What stood out to me is that
> the description of his custom socket implementation matches exactly what
> packet-mmap already is.

The problem is when you first glance at the paper you think its 
something new. So that piece is a little misleading.

> I noticed he only mentioned testing of libpcap-mmap, but did not use
> mmap packet sockets directly -- maybe there's something about libpcap
> that limits performance? I haven't looked.

More than likely turbo packet was used from some of Alexeys old patches-
now obsoleted

> What I can say for sure is that the napi + packet-mmap performance with
> many small packets is almost surely limited by problems with irq/softirq
> load. There was an excellent thread last week about this with Andrea
> Arcangeli, Robert Olsson and others about the balancing of softirq and
> userspace load; they eventually were beginning to agree that running
> softirqs on return from hardirq and bh was a bigger load than expected
> when there was lots of napi work to do. So despite NAPI, too much kernel
> time is spent handling (soft)irq load with many small packets.

I didnt follow that discussion; archived for later entertaining reading.
My take on it was it is 2.6.x related and in particular the misbehavior
observed has to do with use of rcu in the route cache.

> It appears this problem became worse in 2.6 with HZ=1000, because now
> the napi rx softirq work is being done 10X as much on return from the
> timer interrupt.  I'm not sure if a solution was reached.

Robert?

cheers,
jamal
