From: Zdenek Radouch <zdenek@rcn.com>
Subject: Do you know the TCP stack? (127.x.x.x routing)
Date: Sat, 05 Mar 2005 21:20:25 -0500
Message-ID: <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


How can I disable the stack processing for the 127 net?
Can someone estimate the amount of work needed to do that,
and/or point me to the relevant piece of code?

That is, I'd like to treat the 127 net the same as all other network
numbers. Since that is not the case in the current stack,
I want to remove or disable whatever processing there is.
I am using 2.4 kernel.



Here is a long version and a rationale.
I need a truly private network on a device that serves as a router
in someone else's network.  (The device itself has an internal network).
As far as I know, there is no provision for this within the existing network
numbering scheme.  Obviously, the architects of the current  numbering
scheme did not think one could build a router with more than a single
card. Unfortunately, routers are being built today with intelligent
line cards, and there is nothing simpler that the IP/socket based IPC
between Ethernet-connected cards.  The problem is immediately obvious:
one can't use any legal address for the internal network, since it may
collide with an external network the device is handling.  And since
the device can be routing non-Internet addresses, the "reserved"
numbers are as unusable as the normal ones. The only solution I've seen
on routers running BSD stack is to subnet the 127 net, and use one
of the subnets for the internal network.

Unfortunately, this does not work with the Linux stack, because the
127 net is treated (for good reasons I suppose) as a special net.
What I need is to remove whatever special processing there is,
so that the net can be treated as any other net.  Then I could, for
example, attach 127.0.0.1/16 to the "lo" device, and 127.1.0.0/16
would be my internal net, thus keeping the standard 127.0.0.1
address for the localhost, and having a truly private internal network.

So, that's all fine, except for the fact that I am not familiar with the
Linux stack code.  I do need this done, so as a first step I'd like
to get a feeling for the scope of the required modification and
an estimated effort to do this.  As with my previous problem,
if it turns out that this is a non-trivial effort,  I will gladly arrange
a short-term contract for someone in order to be adequately
compensated for the work.

Thanks.
-Zdenek
