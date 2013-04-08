From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK packet
Date: Mon, 08 Apr 2013 17:24:50 -0400
Message-ID: <2921619.mqaHl5PnPI@sifl>
References: <1725553.maWFXblPLa@sifl> <3505145.vfXt1x4t0P@sifl> <20130408.171512.973275376690340387.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	mvadkert@redhat.com, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20130408.171512.973275376690340387.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, April 08, 2013 05:15:12 PM David Miller wrote:
> From: Paul Moore <pmoore@redhat.com>
> Date: Mon, 08 Apr 2013 17:10:43 -0400
> 
> > On Monday, April 08, 2013 02:32:00 PM Paul Moore wrote:
> >> On Monday, April 08, 2013 02:12:01 PM Paul Moore wrote:
> >> > On Monday, April 08, 2013 10:47:47 AM Eric Dumazet wrote:
> >> > > On Mon, 2013-04-08 at 13:40 -0400, Paul Moore wrote:
> >> > > > Sort of a similar problem, but not really the same.  Also,
> >> > > > arguably,
> >> > > > there is no real associated sock/socket for a RST so orphaning the
> >> > > > packet makes sense. In the case of a SYNACK we can, and should,
> >> > > > associate the packet with a sock/socket.
> >> > > 
> >> > > What is the intent ?
> >> > 
> >> > We have to do a number of painful things in SELinux because we aren't
> >> > allowed a proper security blob (void *security) in a sk_buff.  One of
> >> > those things ...
> >> 
> >> Actually, I wonder if this problem means it is a good time to revisit the
> >> no- security-blob-in-sk_buff decision?  The management of the blob would
> >> be hidden behind the LSM hooks like everything else and it would have a
> >> number of advantages including making problems like we are seeing here
> >> easier to fix or avoid entirely.  It would also make life much easier for
> >> those of working on LSM stuff and it would pave the way for including
> >> network access controls in the stacked-LSM stuff Casey is kicking around.
> > 
> > No comment, or am I just too anxious?
> 
> There is no way I'm putting LSM overhead into sk_buff, it's already
> too big.

If the void pointer is wrapped by a #ifdef (plenty of precedence for that) and 
the management of that pointer is handled by LSM hooks why is it a concern?  I 
apologize for pushing on the issue, but I'm having a hard time reconciling the 
reason for the "no" with the comments/decisions about the regression fix; at 
present there seems to be a level of contradiction between the two.

> I didn't comment because it wasn't worth a comment, but since you're
> pushing me on the issue, I'll make the no explicit.

-- 
paul moore
security and virtualization @ redhat

