From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Understanding HFSC
Date: Sat, 03 Dec 2011 23:57:19 -0500
Message-ID: <1322974639.3347.72.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:53208 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753264Ab1LDE5X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Dec 2011 23:57:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, all.  I hope I am in the right place as this seems to be the
place to ask questions formerly asked on lartc.  For the last three
days, I've been banging my head against the wall trying to understand
HFSC and it's finally starting to crack (the wall, not my head although
that's close, too!).  It seems to be wonderful, powerful, mysterious,
and poorly understood.

I'm not sure I understand it either but it also seems much of what is
written about it is written by people who don't fully grasp it, e.g.,
mostly focusing on guaranteed bandwidth and hierarchical sharing but not
spending much time explaining the important concept of decoupling
latency requirements and bandwidth - the part most interesting to us.
So I'm hoping you'll indulge my questions and my attempt to articulate
my understanding to see if I get it or if I've completely missed the
plot!

One of the most confusing bits to me is, does the m1 rate apply to each
flow handled by the class or only to the entire class once it becomes
active? In other words, if I want to ensure that my VoIP packets jump in
front of my FTP bulk transfers as so fascinatingly illustrated on page 4
of http://trash.net/~kaber/hfsc/SIGCOM97.pdf and so specify a steeper m1
slope for the first 10 ms and I have a dozen RTP sessions running, does
that mean that as many sessions as snuck a packet into the first 10 ms
received that prioritized treatment and all the rest are treated at the
m2 rate or is the 10ms acceleration in deadline time applied to every
new RTP flow? I'm hoping the latter but it didn't appear to be
explicitly stated.

Perhaps it is even better illustrated by an example posted on
https://calomel.org/pf_hfsc.html where they describe a web server
serving its 10KB of text and then some large data files.  So if I set
umax=80kbits and dmax=200ms so that I deliver the first 10KB text of the
web page with no more than 200ms delay and then send the rest of the
images, videos, etc., at the m2 rate, what happens with multiple users?
The first user goes to the site, pulls down the 10KB text and then
starts on the 10MB video (assuming they are not pipelining).  This puts
the hfsc class firmly into m2.  A new user comes in while the first user
is still downloading the video.  Is the first 10KB for the second user
scheduled at the m2 rate or does m1 kick in to determine deadline and
jump those text packets in front of both the http video download and any
bulk file transfers that might be happening at the same time?

Second, what must go into the umax size? Let's assume we want umax to be
a single maximum sized packet on a non-jumbo frame Ethernet network.
Should umax be:
1500
1514 (add Ethernet)
1518 (add CRC)
1526 (add preamble)
1538 (add interframe gap)?

To keep this email from growing any longer, I'll put the rest in a
separate email? Thanks - John
