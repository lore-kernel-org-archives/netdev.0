From: "James Nichols" <jamesnichols3@gmail.com>
Subject: After many hours all outbound connections get stuck in SYN_SENT
Date: Sun, 16 Dec 2007 11:34:29 -0500
Message-ID: <83a51e120712160834r29112fb0xa1f61c35f180bf8f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:26085 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933209AbXLPQeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 11:34:31 -0500
Received: by fg-out-1718.google.com with SMTP id e21so190867fga.17
        for <netdev@vger.kernel.org>; Sun, 16 Dec 2007 08:34:30 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have a Java application that makes a large number of outbound
webservice calls over HTTP/TCP.  The hosts contacted are a fixed set
of about 2000 hosts and a web service call is made to each of them
approximately every 5 mintues by a pool of 200 Java threads.  Over
time, on average a percentage of these hosts are unreachable for one
reason or another, usually because they are on wireless cell phone
NICs, so there is a persistent count of sockets in the SYN_SENT state
in the range of about 60-80.  This is fine, as these failed connection
attempts eventually time out.

However, after approximately 38 hours of operation, all outbound
connection attempts get stuck in the SYN_SENT state.  It happens
instantaneously, where I go from the baseline of about 60-80 sockets
in SYN_SENT to a count of 200 (corresponding to the # of java threads
that make these calls).

When I stop and start the Java application, all the new outbound
connections still get stuck in SYN_SENT state.  During this time, I am
still able to SSH to the box and run wget to Google, cnn, etc, so the
problem appears to be specific to the hosts that I'm accessing via the
webservices.

For a long time, the only thing that would resolve this was rebooting
the entire machine.  Once I did this, the outbound connections could
be made succesfully.  However, very recently when I had once of these
incidents I disabled tcp_sack via:

echo "0" > /proc/sys/net/ipv4/tcp_sack

And the problem almost instanteaously resolved itself and outbound
connection attempts were succesful.  I hadn't attempted this before
because I assumed that if any of my network
equipment or remote hosts had a problem with SACK, that it would never
work.  In my case, it worked fine for about 38 hours before hitting a
wall where no outbound connections could be made.

I'm running kernel 2.6.18 on RedHat, but have had this problem occur
on earlier kernel versions (all 2.4 and 2.6).  I know a lot of people
will say it must be the firewall, but I've seen had this issue on
different router vendors, firewall vendors, different co-location
facilities, NICs, and several other variables.  I've totaly rebuilt
every piece of the archtiecture at one time or another and still see
this issue.  I've had this problem to varying degrees of severity for
the past 4 years or so.  Up until this point, the only thing other
than a complete machine restart that fixes the problem is disabling
tcp_sack.  When I disable it, the problem goes away almost
instantaneously.

Is there a kernel buffer or some data structure that tcp_sack uses
that gets filled up after an extended period of operation?
How can I debug this problem in the kernel to find out what the root cause is?

I emailed linux-kernel and they asked for output of netstat -s, I can
get this the next
time it occurs- any other usefull data to collect?

I've temporarily signed up on this list, but may cancel signup if I can't
handle the traffic, so please CC me directly on any replies.

Thanks,

James Nichols
